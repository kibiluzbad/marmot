#
# Created on Fri Nov 25 2016
#
# Copyright (c) 2016 Your Company
#

require 'has_properties'

module MarmotBuild
  # Public: Create a new docker container suing given Docker image.
  #
  # Examples:
  #   image = ...
  #   create_container = MarmotBuild::KillContainer(image: image)
  #   create_container.exec
  #   #=> <Container>
  class CreateContainer
    include HasProperties

    # Public: Get/Set image.
    properties :image

    # Public: Create and start new docker container using given Docker image object.
    #
    # Returns container object.
    def exec
      container = Docker::Container.create(Image: image.id,
                                           Cmd: ['bash'],
                                           Tty: true)
      container.start
      container
    end
  end
end
