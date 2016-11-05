require 'rails_helper'

RSpec.describe BuildConfig, type: :model do
  # it { should validate_presence_of :image }
  # it { should validate_presence_of :build_steps }
  # it { should validate_presence_of :language }

  subject(:build_config) do
    BuildConfig.new(image: 'node',
                    build_steps: ['npm install', 'npm exec build'],
                    language: 'node')
  end

  context 'when calling laguage version' do
    xit 'set and get <language>_version' do
      version = '6.6.0'
      build_config.node_version(version)
      node_version = build_config.node_version
      expect(node_version).to eq version
    end

    xit 'responds to <language>_version' do
      expect(build_config.respond_to?('node_version')).to be true
    end

    context 'with invalid language' do
      xit 'raise NoMethodError exception' do
        expect do
          build_config.ruby_version('2.3.1')
        end.to raise_error(NoMethodError)
      end
    end
  end
end
