#
# Created on Fri Nov 25 2016
#
# Copyright (c) 2016 Your Company
#

# Public: Build job. Creates new build and execute it.
#
# Examples:
#  BuildJob.perform_later project: 'Marmot',
#                         commit: 'a2922d479924b52bf48909d7c51088d8c1425576'
class BuildJob < ApplicationJob
  queue_as :default

  # Public: Perform job activity.
  #
  # args - Hash with :project and :commit.
  def perform(*args)
    arg = args[0]
    project = Project.where(name: arg[:project]).first

    build = Build.create(project: project,
                         commit: arg[:commit],
                         status: 'created')

    build.exec
  end
end
