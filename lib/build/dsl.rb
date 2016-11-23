require 'build/docker_runner'
module MarmotBuild
  module DSL
    include MarmotBuild::DockerRunner

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
