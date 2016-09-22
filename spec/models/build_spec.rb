require 'rails_helper'

RSpec.describe Build, type: :model do
  it { should validate_presence_of(:commit) }

  it 'builds project should load build config' do
    # TODO: Use factory girl
    project = Project.create(name: 'Node Test Project',
                             language: 'node')

    new_build = Build.create(commit: '2a46156e99f8207601ba1fb578bd5c5dec6c92f5',
                             project: project)

    new_build.exec

    expect(new_build.build_config).not_to be_nil

  end
end
