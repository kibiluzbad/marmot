#
# Created on Fri Nov 25 2016
#
# Copyright (c) 2016 Your Company
#

require 'docker'
require 'build/build_image'
require 'build/create_container'
require 'build/exec_command'
require 'build/kill_container'

module MarmotBuild
  # Public: Docker runner build methods. Should be used within Build entity.
  #
  # Examples:
  #
  #   class Build
  #     ...
  #     include MarmotBuild::DSL
  #     ...
  #     has_one :build_config
  #     field :marmot_file_path, type: String
  #     field :output, type: Text
  #
  #     def started
  #       ...
  #     end
  #
  #     def running
  #       ...
  #     end
  #
  #     def success
  #       ...
  #     end
  #
  #     def failed(message = nil)
  #       ...
  #     end
  #
  #     def append_to_log(message)
  #       ...
  #     end
  #
  #   end
  #   module DSL
  #     include MarmotBuild::DockerRunner
  #
  #     def build(yaml_file)
  #       ...
  #       create_docker_file
  #       run
  #       ...
  #     end
  #   end
  module DockerRunner
    # Public: Create docker file for curretn build using build_config property
    # values.
    #
    # Returns path to Dockerfile.
    def create_docker_file
      path = File.expand_path("../../../builds/#{id}", __FILE__)
      File.open(path, 'wb') { |f| f.write(add_build_steps(set_content)) }
      path
    end

    # Public: Run build by creating Docker image, using build's Dockerfile.
    # Then a container is created to run build_steps and build_tests commands.
    # After that kills container. Log is streamed to Build object.
    #
    # Returns Docker Image id.
    def run
      running
      image = MarmotBuild::BuildImage.new(build: self).exec
      return nil if image.nil?
      container = MarmotBuild::CreateContainer.new(image: image).exec
      exec_build_and_tests container
      success if status != 'failed'
      image.id
    rescue StandardError => e
      failed(e.message)
    ensure
      MarmotBuild::KillContainer.new(container: container).exec unless container.nil?
    end


    private

    # Private: Split command string into an array creating an array with each word
    # in all commands.
    #
    # Returns new Array with commands.
    def map_commands(commands)
      result = []
      commands.each { |c| result.push(*c.split(' ')) }

      result
    end

    # Private: Set Dockerfile content.
    #
    # Returns Dockerfile content.
    def set_content
      version = build_config.version || 'latest'
      content = "FROM #{build_config.image}:#{version}\r\n"\
      "RUN apt-get update\r\n"\
      "RUN apt-get install git -y\r\n"\
      "RUN mkdir -p /app/current\r\n"\
      "WORKDIR /app/current\r\n"\
      "RUN touch /#{commit} \r\n"\
      "RUN git clone #{project.repository.url} /app/current\r\n"
      content
    end

    # Private: Adds build_steps (if any) to Dockerfile content.
    #
    # content - Dockerfile content.
    #
    # Returns Dockerfile content.
    def add_build_steps(content)
      unless build_config.setup_steps.nil?
        build_config.setup_steps.each do |step|
          content += "RUN #{step}\r\n"
        end
      end
      content
    end

    # Private: Execure buils_steps and test_setps by calling MarmotBuild::ExecCommand.
    #
    # container - Docker container to run commands.
    #
    # Returns nothing.
    def exec_build_and_tests(container)
      [build_config.build_steps || [],
       build_config.test_steps || []].each do |commands|
        ok = MarmotBuild::ExecCommand.new(commands: map_commands(commands),
                                          build: self,
                                          container: container).exec
        unless ok
          failed
          break
        end
      end
    end

  end
end
