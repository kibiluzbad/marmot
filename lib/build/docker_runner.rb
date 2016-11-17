require 'docker'

module MarmotBuild
  class DockerPipeline
    attr_reader :commands, :build, :container
    def initialize(*attrs)
      @commands= attrs[:commands]
      @build = attrs[:build]
      @container = attrs[:container]
    end

    def exec
    end
  end

  class BuildImage 
    attr_accessor :build
    def initialize(*attrs)
      @build = attrs[:build]
    end 
  
    def build 
      build_error = false
      path = File.expand_path('../../../builds', __FILE__)
      build.output = ''
      image = Docker::Image.build_from_dir(path, dockerfile: id) do |v|
        log = JSON.parse(v)
        if log && log.key?('stream')
          build.output += log['stream']
          build.save
        elsif log && log.key?('errorDetail')
          build.output += log['errorDetail']
          build_error = true
          build.save
        end
      end

      if build_error
        build.status = 'failed'
        build.save
        return nil
      end
      image
    end
  end

  class CreateContainer
    attr_reader :image

    def initialize(image)
      @image = image
    end

    def exec
      container = Docker::Container.create(Image: image.id,
                                            Cmd: ['bash'],
                                            Tty: true)
      container.start
      container
    end
  end

  class KillContainer
    attr_reader :container

    def initialize(container)
      @container = container
    end

    def exec
      return nil if container.nil?
      container.stop
      container.delete
    end
  end

  class ExecCommand < DockerPipeline

    def exec
      build_error = false
      container.exec(commands, wait: 3600) do |stream, chunk|
        build_error = true if stream == :stderr
        build.output += "\e[31m#{chunk}\e[0m" if build_error
        build.output += chunk unless build_error
        build.save
      end

      if build_error
        build.status = 'failed'
        build.save
        return nil
      end
      container
    end
  end

 
  module DockerRunner
    def create_docker_file

      content = "FROM #{build_config.image}:#{build_config.version || 'latest'}\r\n"
      content += "RUN apt-get update\r\n"
      content += "RUN apt-get install git -y\r\n"
      content += "RUN mkdir -p /app/current\r\n"
      content += "WORKDIR /app/current\r\n"
      content += "RUN touch /#{commit} \r\n"
      content += "RUN git clone #{project.repository.url} /app/current\r\n"

      unless build_config.setup_steps.nil?
        build_config.setup_steps.each do |step|
          content += "RUN #{step}\r\n"
        end
      end

      path = File.expand_path("../../../builds/#{id}", __FILE__)
      File.open(path, 'wb') { |f| f.write(content) }
      path
    end

    def run
      begin
        image = BuildImage.new(build: self).build
        container = CreateContainer.new(image: image).exec

        [build_config.build_steps, build_config.test_steps].each do |commands|
          ExecCommand.new(commands: map_commands(commands),
                          build: build,
                          container: container).exec
        end
        KillContainer.new(container: container).exec
        image.id
      rescue StandardError => e
          self.status = 'failed'
          self.output = '' if self.output.nil? 
          self.output += e.message
          puts e
          save
      end
    end

    def map_commands(commands)
      commands.map { |c| commands.push(*c.split(' ')) }
    end
  end
end
