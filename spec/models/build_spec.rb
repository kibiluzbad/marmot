require 'rails_helper'

RSpec.describe Build, type: :model do
  xit { should validate_presence_of(:commit) }

  xit 'build exec project should load build config' do
    # TODO: Use factory girl
    project = Project.create(name: 'Node Test Project',
                             language: 'node')
    repo = Repository.create(url: 'https://github.com/sequelize/express-example.git',
                             project: project)

    new_build = Build.create(commit: '2a46156e99f8207601ba1fb578bd5c5dec6c92f5',
                             project: project,
                             marmot_file_path: File.expand_path('../../../test-project/marmot.yml', __FILE__))

    new_build.exec

    expect(new_build.build_config).not_to be_nil

  end

  xit 'build exec should set buildconfig language_version' do
    # TODO: Use factory girl
    
    project = Project.create(name: 'Node Test Project',
                             language: 'node')
    repo = Repository.create(url: 'https://github.com/sequelize/express-example.git',
                             project: project)                         
    new_build = Build.create(commit: '2a46156e99f8207601ba1fb578bd5c5dec6c92f5',
                             project: project,
                             marmot_file_path: File.expand_path('../../../test-project/marmot.yml', __FILE__))

    new_build.exec

    expect(new_build.build_config.node_version).to eq('7.0.0')
  end

  xit 'build exec should set buildconfig language' do
    # TODO: Use factory girl
    project = Project.create(name: 'Node Test Project',
                             language: 'node')
    repo = Repository.create(url: 'https://github.com/sequelize/express-example.git',
                             project: project)

    new_build = Build.create(commit: '2a46156e99f8207601ba1fb578bd5c5dec6c92f5',
                             project: project,
                             marmot_file_path: File.expand_path('../../../test-project/marmot.yml', __FILE__))

    new_build.exec

    expect(new_build.build_config.language).to eq('node')

  end

  xit 'build exec should set buildconfig image' do
    # TODO: Use factory girl
    project = Project.create(name: 'Node Test Project',
                             language: 'node')
    repo = Repository.create(url: 'https://github.com/sequelize/express-example.git',
                             project: project)

    new_build = Build.create(commit: '2a46156e99f8207601ba1fb578bd5c5dec6c92f5',
                             project: project,
                             marmot_file_path: File.expand_path('../../../test-project/marmot.yml', __FILE__))

    new_build.exec

    expect(new_build.build_config.image).to eq('node')

  end

  xit 'build exec should set buildconfig build_steps' do
    # TODO: Use factory girl
    project = Project.create(name: 'Node Test Project',
                             language: 'node')
    repo = Repository.create(url: 'https://github.com/sequelize/express-example.git',
                             project: project)

    new_build = Build.create(commit: '2a46156e99f8207601ba1fb578bd5c5dec6c92f5',
                             project: project,
                             marmot_file_path: File.expand_path('../../../test-project/marmot.yml', __FILE__))

    new_build.exec

    expect(new_build.build_config.build_steps).to include('npm install')

  end

  xit 'build exec should set buildconfig test_steps' do
    # TODO: Use factory girl
    project = Project.create(name: 'Node Test Project',
                             language: 'node')
    repo = Repository.create(url: 'https://github.com/sequelize/express-example.git',
                             project: project)

    new_build = Build.create(commit: '2a46156e99f8207601ba1fb578bd5c5dec6c92f5',
                             project: project,
                             marmot_file_path: File.expand_path('../../../test-project/marmot.yml', __FILE__))

    new_build.exec

    expect(new_build.build_config.test_steps).to include('npm test')

  end

  xit 'build exec should set buildconfig setup_steps' do
    # TODO: Use factory girl
    project = Project.create(name: 'Node Test Project',
                             language: 'node')
    repo = Repository.create(url: 'https://github.com/sequelize/express-example.git',
                             project: project)

    new_build = Build.create(commit: '2a46156e99f8207601ba1fb578bd5c5dec6c92f5',
                             project: project,
                             marmot_file_path: File.expand_path('../../../test-project/marmot.yml', __FILE__))

    new_build.exec

    expect(new_build.build_config.setup_steps).to include('npm update -g npm')

  end
end
