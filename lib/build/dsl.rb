#
# Created on Fri Nov 25 2016
#
# Copyright (c) 2016 Your Company
#

require 'build/docker_runner'

module MarmotBuild
  # Public: Build dsl module.
  #
  # Examples:
  #
  #   class Build
  #     ...
  #     include MarmotBuild::DSL
  #     ...
  #   def exec
  #     ...
  #     build YAML.load(project.repository.get_marmot_file(commit))
  #     ...
  #   end
  #
  #   end
  module DSL
    include MarmotBuild::DockerRunner

    # Public: Builds current version of code using given YAML file.
    #
    # yaml_file - Yaml file already loaded.
    #
    # Returns Docker Image id.
    def build(yaml_file)
      language_version = project.language + '_version'

      version     yaml_file[language_version]
      image       yaml_file['image']
      build_steps yaml_file['build']
      test_steps  yaml_file['test']
      setup_steps yaml_file['setup']

      create_docker_file
      run
    end
  end
end
