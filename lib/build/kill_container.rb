#
# Created on Fri Nov 25 2016
#
# Copyright (c) 2016 Your Company
#

require 'has_properties'

module MarmotBuild
  # Public: Kills running docker container.
  #
  # Examples:
  #   container = ...
  #   kill_container = MarmotBuild::KillContainer(container: container)
  #   kill_container.exec
  #   #=> True
  class KillContainer
    include HasProperties

    # Public: Get/Set container.
    properties :container

    # Public: Stop and delete running docker container.
    #
    # Returns nothing.
    def exec
      return nil if container.nil?
      container.stop
      container.delete
    end
  end
end
