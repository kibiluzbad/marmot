#
# Created on Fri Nov 25 2016
#
# Copyright (c) 2016 Your Company
#

# Public: Project entity.
class Project
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  has_many :builds
  has_one :repository

  validates :name, presence: true
  validates :language, presence: true

  field :name,     type: String
  field :language, type: String
end
