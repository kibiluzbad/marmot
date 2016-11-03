require 'docker'

module MarmotBuild
  module DockerRunner
    def create_docker_file
      
      content = "FROM #{build_config.image}:#{build_config.version || 'latest'}\r\n"
      content += "RUN apt-get update\r\n"
      content += "RUN apt-get install git -y\r\n"
      content += "RUN mkdir -p /app/current\r\n"
      content += "WORKDIR /app/current\r\n"
      content += "RUN git clone #{project.repository.url} /app/current\r\n"
      
      if !build_config.setup_steps.nil?
        build_config.setup_steps.each do |step|
          content += "RUN #{step}\r\n"
        end
      end
      
      path = File.expand_path("../../../builds/#{id}", __FILE__)
      File.open(path, 'wb') { |f| f.write(content) }
      path
    end
    
    def run
      path = File.expand_path('../../../builds', __FILE__)
      self.output = ''
      image = Docker::Image.build_from_dir(path, dockerfile: id)do |v|
        if (log = JSON.parse(v)) && log.has_key?("stream")
          self.output += log["stream"]
          save
        end
      end

      commands = []

      build_config.build_steps.each do |c|
        commands.push(*c.split(' '))
      end
      
      container = Docker::Container.create(Image: image.id,
                                            Cmd: commands)
      container.start
      self.status = 'running'
      save
      container.wait(3600)
      error = false
      container.streaming_logs(stdout: true) do |stream, chunk|
        self.output += chunk
        error = true if stream == 'stderr'
        save
      end
      
      self.status = 'success' unless error
      self.status = 'failed' if error
      save
      container.stop
      container.delete
      image.id
    end
  end
end
