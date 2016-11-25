#
# Created on Fri Nov 25 2016
#
# Copyright (c) 2016 Your Company
#

require 'has_properties'

module MarmotBuild
  # Public: Build new docker image using Build's Dockerfile.
  #
  # Examples:
  #   build = ...
  #   build_image = MarmotBuild::BuildImage(build: build)
  #   build_image.exec
  #   #=> <Image>
  class BuildImage
    include HasProperties

    # Public: Get/Set build.
    properties :build

    # Public: Create new Docker Image streaming it's log to build object.
    # Fails build if any errors occur.
    #
    # Returns Image object.
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

    # Private: Build image from docker file.
    #
    # Returns Image object.
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
end
