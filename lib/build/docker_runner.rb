require 'docker'

module HasProperties
  attr_accessor :props

  def has_properties(*args)
    @props = args
    instance_eval { attr_reader *args }
  end

  def self.included(base)
    base.extend self
  end

  def initialize(args)
    args.each do |k, v|
      instance_variable_set "@#{k}", v if self.class.props.member?(k)
    end if args.is_a? Hash
  end
end

module MarmotBuild
  class BuildImage
    include HasProperties

    has_properties :build

    def exec
      @build_error = false
      path = File.expand_path('../../../builds', __FILE__)
      image = create_image path

      if @build_error
        build.failed('')
        return nil
      end
      image
    end

    private

    def create_image(path)
      Docker::Image.build_from_dir(path, dockerfile: build.id) do |v|
        log = JSON.parse(v)
        if log && log.key?('stream')
          build.append_to_log log['stream']
        elsif log && log.key?('errorDetail')
          build.append_to_log log['errorDetail']
          @build_error = true
        end
      end
    end
  end

  class CreateContainer
    include HasProperties

    has_properties :image

    def exec
      container = Docker::Container.create(Image: image.id,
                                           Cmd: ['bash'],
                                           Tty: true)
      container.start
      container
    end
  end

  class KillContainer
    include HasProperties

    has_properties :container

    def exec
      return nil if container.nil?
      container.stop
      container.delete
    end
  end

  class ExecCommand
    include HasProperties

    has_properties :commands, :build, :container

    def exec
      build_error = false
      container.exec(commands, wait: 3600) do |stream, chunk|
        build_error = stream == :stderr
        build.append_to_log("\e[31m#{chunk}\e[0m") if build_error
        build.append_to_log(chunk) unless build_error
      end

      !build_error
    end
  end

  module DockerRunner
    def create_docker_file
      unless build_config.setup_steps.nil?
        build_config.setup_steps.each do |step|
          content += "RUN #{step}\r\n"
        end
      end

      path = File.expand_path("../../../builds/#{id}", __FILE__)
      File.open(path, 'wb') { |f| f.write(set_content) }
      path
    end

    def run
      running
      image = BuildImage.new(build: self).exec
      return nil if image.nil?
      container = CreateContainer.new(image: image).exec
      exec_build_and_tests container
      success if status != 'failed'
      KillContainer.new(container: container).exec
      image.id
    rescue StandardError => e
      failed(e.message)
    end

    def map_commands(commands)
      result = []
      commands.each { |c| result.push(*c.split(' ')) }

      result
    end

    def set_content
      content = "FROM #{build_config.image}:#{build_config.version || 'latest'}\r\n"\
      "RUN apt-get update\r\n"\
      "RUN apt-get install git -y\r\n"\
      "RUN mkdir -p /app/current\r\n"\
      "WORKDIR /app/current\r\n"\
      "RUN touch /#{commit} \r\n"\
      "RUN git clone #{project.repository.url} /app/current\r\n"
      content
    end

    def exec_build_and_tests(container)
      [build_config.build_steps || [],
       build_config.test_steps || []].each do |commands|
        command_ok = ExecCommand.new(commands: map_commands(commands),
                                     build: self,
                                     container: container).exec
        unless command_ok
          failed
          break
        end
      end
    end
  end
end
