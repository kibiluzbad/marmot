require 'docker'

module MarmotBuild

  class BuildImage 
    attr_accessor :build
    def initialize(attrs)
      attrs.each { |k, v| public_send("#{k}=", v) }
    end 
  
    def exec 
      build_error = false
      path = File.expand_path('../../../builds', __FILE__)
      build.output = ''
      image = Docker::Image.build_from_dir(path, dockerfile: build.id) do |v|
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
        build.failed('')
        return nil
      end
      image
    end
  end

  class CreateContainer
    attr_accessor :image

    def initialize(attrs)
      attrs.each { |k, v| public_send("#{k}=", v) }
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
    attr_accessor :container

    def initialize(attrs)
      attrs.each { |k, v| public_send("#{k}=", v) }
    end

    def exec
      return nil if container.nil?
      container.stop
      container.delete
    end
  end

  class ExecCommand
    attr_accessor :commands, :build, :container

    def initialize(attrs)
      attrs.each { |k, v| public_send("#{k}=", v) }
    end

    def exec
      build_error = false
      container.exec(commands, wait: 3600) do |stream, chunk|
        build_error = true if stream == :stderr
        build.output += "\e[31m#{chunk}\e[0m" if build_error
        build.output += chunk unless build_error
        build.save
      end

      !build_error
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
        running
        image = BuildImage.new(build: self).exec
        return nil if image.nil?
        container = CreateContainer.new(image: image).exec

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
        KillContainer.new(container: container).exec
        image.id
      rescue StandardError => e
          failed(e.message)
          puts e
          Rails.logger.fatal e
      end
    end

    def map_commands(commands)
      result = []
      commands.each { |c| result.push(*c.split(' ')) }
      
      result
    end
  end
end
