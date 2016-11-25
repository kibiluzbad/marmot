#
# Created on Fri Nov 25 2016
#
# Copyright (c) 2016 Your Company
#

require 'git'

# Public: Respository entity.
class Repository
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  belongs_to :project

  validates :url, presence: true

  field :url, type: String

  # Public: Clone or Open git repo.
  #
  # commit - Git commit value.
  #
  # Examples:
  #  repo = ...
  #  repo.clone 'a2922d479924b52bf48909d7c51088d8c1425576'
  #  #=> <Git>
  #
  # Returns Git repo object.
  def clone(commit)
    repos_path = File.expand_path('repos')
    repo_path = File.join(repos_path, commit)
    @git = Git.open(repo_path) if FileTest.exist?(repo_path)
    @git = Git.clone(url, commit, path: repos_path) if @git.nil?
  end

  # Public: Get marmot file content from repository.
  #
  # commit - Git commit value.
  #
  # Examples:
  #  repo = ...
  #  repo.get_marmot_file 'a2922d479924b52bf48909d7c51088d8c1425576'
  #  #=> "..."
  #
  # Returns marmot file content.
  def get_marmot_file(commit)
    clone(commit) if @git.nil?
    @git.show(commit, 'marmot.yml')
  end

  # Public: Get path to git repo.
  #
  # commit - Git commit value.
  #
  # Examples:
  #  repo = ...
  #  repo.get_path 'a2922d479924b52bf48909d7c51088d8c1425576'
  #  #=> "/app/current/repos/a2922d479924b52bf48909d7c51088d8c1425576"
  #
  # Returns git repo path.
  def get_path(commit)
    repos_path = File.expand_path('repos')
    File.join(repos_path, commit)
  end
end
