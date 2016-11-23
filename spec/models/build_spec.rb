require 'rails_helper'

RSpec.describe Build, type: :model do
  it { should validate_presence_of(:commit) }

  it 'build exec project should load build config' do
    # TODO: Use factory girl
    project = Project.create(name: 'Marmot',
                             language: 'ruby')
    repo = Repository.create(url: 'https://github.com/kibiluzbad/marmot.git',
                             project: project)

    new_build = Build.create(commit: '412f93baf924187b077f57c90a4fa01b8839de7e',
                             project: project,
                             marmot_file_path: File.expand_path('../../../marmot.yml', __FILE__))

    new_build.exec

    expect(new_build.build_config).not_to be_nil
  end

  it 'build exec should set buildconfig language_version' do
    # TODO: Use factory girl

    project = Project.create(name: 'Marmot',
                             language: 'ruby')
    repo = Repository.create(url: 'https://github.com/kibiluzbad/marmot.git',
                             project: project)
    new_build = Build.create(commit: '412f93baf924187b077f57c90a4fa01b8839de7e',
                             project: project,
                             marmot_file_path: File.expand_path('../../../marmot.yml', __FILE__))

    new_build.exec

    expect(new_build.build_config.ruby_version).to eq('latest')
  end

  it 'build exec should set buildconfig language' do
    # TODO: Use factory girl
    project = Project.create(name: 'Marmot',
                             language: 'ruby')
    repo = Repository.create(url: 'https://github.com/kibiluzbad/marmot.git',
                             project: project)

    new_build = Build.create(commit: '412f93baf924187b077f57c90a4fa01b8839de7e',
                             project: project,
                             marmot_file_path: File.expand_path('../../../marmot.yml', __FILE__))

    new_build.exec

    expect(new_build.build_config.language).to eq('ruby')
  end

  it 'build exec should set buildconfig image' do
    # TODO: Use factory girl
    project = Project.create(name: 'Marmot',
                             language: 'ruby')
    repo = Repository.create(url: 'https://github.com/kibiluzbad/marmot.git',
                             project: project)

    new_build = Build.create(commit: '412f93baf924187b077f57c90a4fa01b8839de7e',
                             project: project,
                             marmot_file_path: File.expand_path('../../../marmot.yml', __FILE__))

    new_build.exec

    expect(new_build.build_config.image).to eq('tortxof/ruby-node')
  end

  it 'build exec should set buildconfig build_steps' do
    # TODO: Use factory girl
    project = Project.create(name: 'Marmot',
                             language: 'ruby')
    repo = Repository.create(url: 'https://github.com/kibiluzbad/marmot.git',
                             project: project)

    new_build = Build.create(commit: '412f93baf924187b077f57c90a4fa01b8839de7e',
                             project: project,
                             marmot_file_path: File.expand_path('../../../marmot.yml', __FILE__))

    new_build.exec

    expect(new_build.build_config.build_steps).to include('bundle install')
  end

  it 'build exec should set buildconfig test_steps' do
    # TODO: Use factory girl
    project = Project.create(name: 'Marmot',
                             language: 'ruby')
    repo = Repository.create(url: 'https://github.com/kibiluzbad/marmot.git',
                             project: project)

    new_build = Build.create(commit: '412f93baf924187b077f57c90a4fa01b8839de7e',
                             project: project,
                             marmot_file_path: File.expand_path('../../../marmot.yml', __FILE__))

    new_build.exec

    expect(new_build.build_config.test_steps).to include('bundle exec rspec')
  end

  it 'build exec should set buildconfig setup_steps' do
    # TODO: Use factory girl
    project = Project.create(name: 'Marmot',
                             language: 'ruby')
    repo = Repository.create(url: 'https://github.com/kibiluzbad/marmot.git',
                             project: project)

    new_build = Build.create(commit: '412f93baf924187b077f57c90a4fa01b8839de7e',
                             project: project,
                             marmot_file_path: File.expand_path('../../../marmot.yml', __FILE__))

    new_build.exec

    expect(new_build.build_config.setup_steps).to be nil
  end
end
