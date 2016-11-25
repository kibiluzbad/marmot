#
# Created on Fri Nov 25 2016
#
# Copyright (c) 2016 Your Company
#

# == BuildsController
#
# Actions for builds resource
class BuildsController < ApplicationController
  def index
    render json: Build.all.to_json
  end

  def create
    return head :unprocessable_entity unless params[:commit].present?
    return head :unprocessable_entity unless params[:project].present?

    BuildJob.perform_later project: params[:project],
                           commit: params[:commit]

    head :created
  end
end
