#
# Created on Fri Nov 25 2016
#
# Copyright (c) 2016 Your Company
#

require 'has_properties'

module MarmotBuild
  # Public: Execute Docker commands class. Is used to call exec on
  # commands to a running docker container.
  #
  # Examples:
  #   container = ...
  #   build = ...
  #   commands = ['bundle','exec','rails','s']
  #   exec_command = MarmotBuild::ExecCommand(container: container,
  #                                           build: build,
  #                                           commands: commands)
  #   exec_command.exec
  #   #=> True
  class ExecCommand
    include HasProperties

    # Public: Get/Set commands, build and container.
    properties :commands, :build, :container

    # Public: Execute commands on running container.
    #
    # Returns True if no errors occured otherwise False.
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
end
