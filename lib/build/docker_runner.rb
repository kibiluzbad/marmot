require 'docker'

module MarmotBuild
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
        build_error = false
        path = File.expand_path('../../../builds', __FILE__)
        self.output = ''
        image = Docker::Image.build_from_dir(path, dockerfile: id) do |v|
          log = JSON.parse(v)
          if log && log.key?('stream')
            self.output += log['stream']
            save
          elsif log && log.key?('error')
            self.output += log['error']
            build_error = true
            save
          end
        end

        if build_error
          self.status = 'failed'
          save
          return nil
        end

        commands = []

        build_config.build_steps.each do |c|
          commands.push(*c.split(' '))
        end

        container = Docker::Container.create(Image: image.id,
                                            Cmd: ['bash'],
                                            Tty: true)
        container.start
        self.status = 'running'
        save
        
        container.exec(commands, wait: 3600) do |stream, chunk|

          build_error = true if stream == :stderr
          self.output += "\e[31m#{chunk}\e[0m" if build_error
          self.output += chunk unless build_error 
          save
        end

        if build_error
          self.status = 'failed'
          save
          return nil
        end

        commands = []
        build_config.test_steps.each do |c|
          commands.push(*c.split(' '))
        end

        container.exec(commands, wait: 3600) do |stream, chunk|
          build_error = true if stream == :stderr
          self.output += "\e[31m#{chunk}\e[0m" if build_error
          self.output += chunk unless build_error 
          save
        end

        self.status = 'success' unless build_error
        self.status = 'failed' if build_error
        save
        container.stop
        container.delete
        image.id
      rescue Exception => e
          self.status = 'failed'
          self.output += e.message
          puts e
          save
      end
    end
  end
end
