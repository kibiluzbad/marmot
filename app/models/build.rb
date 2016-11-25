#
# Created on Fri Nov 25 2016
#
# Copyright (c) 2016 Your Company
#

require 'yaml'
require 'build/dsl'

# Public: Build entity.
class Build
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
  include MarmotBuild::DSL

  METHODS_ALLOWED = %w(version image build_steps test_steps setup_steps).freeze

  validates :commit, presence: true

  belongs_to :project
  has_one :build_config

  field :commit, type: String
  field :marmot_file_path, type: String
  field :output, type: Text
  field :status, type: String

  # Public: Execute build using MarmotBuild::DSL.
  def exec
    started
    project.repository.clone commit
    config = load_config
    build YAML.load(project.repository.get_marmot_file(commit))
    config.save
    save
  end

  # Public: Change build status to started and broadcast change message.
  def started
    self.status = 'started'
    broadcast_message property: :status,
                      value: status
  end

  # Public: Change build status to running and broadcast change message.
  def running
    self.status = 'running'
    broadcast_message property: :status,
                      value: status
  end

  # Public: Change build status to success and broadcast change message.
  def success
    self.status = 'success'
    broadcast_message property: :status,
                      value: status
  end

  # Public: Change build status to failed, append message to log (if any)
  # and broadcast change message.
  def failed(message = nil)
    self.status = 'failed'
    append_to_log message
    broadcast_message property: :status,
                      value: status
  end

  # Public: Append message to output (if any) and boardcast change message.
  def append_to_log(message)
    self.output = '' if output.nil?
    self.output += message unless message.nil?
    broadcast_message property: :output,
                      value: self.output
  end

  # Public: Overwrite method_missing to answer to build_config properties directly.
  def method_missing(method_name, *args, &block)
    if METHODS_ALLOWED.include? method_name.to_s
      build_config[method_name] = args.first
    else
      super
    end
  end

  # Public: Overwrite respond_to_missing to answer to build_config properties directly.
  def respond_to_missing?(method_name, include_private = false)
    METHODS_ALLOWED.include?(method_name.to_s) || super
  end

  protected

  # Protected: Create new build_config.
  #
  # Returns BuildConfig.
  def load_config
    BuildConfig.create(build: self, language: project.language)
  end

  # Protected: Broadcast change messages to 'messages' channel using ActionCable.
  #
  # args - Hash containing :property and :value values.
  #
  # Examples:
  #   broadcast_message property: :output,
  #                     value: 'new output'
  def broadcast_message(args)
    ActionCable.server.broadcast 'messages',
                                 property: args[:property],
                                 newValue: args[:value]
  end
end
