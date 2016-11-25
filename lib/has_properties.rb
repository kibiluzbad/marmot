# Public: Constructor and method helper for hash initialized properties.
#
# Examples
#
#   class BuildImage
#     include HasProperties
#
#     properties :build
#     ...
#   end
module HasProperties
  # Public: Get\Set desired propeties set by properties helper.
  attr_accessor :props

  # Public: Helper method to set attr_accessor properties.
  #
  # args - Array of properties to create attr_accessor's.
  #
  # Examples
  #
  #   class BuildImage
  #     include HasProperties
  #
  #     properties :build
  #     ...
  #   end
  # Returns nothing.
  def properties(*args)
    @props = args
    instance_eval { attr_reader(*args) }
  end

  def self.included(base)
    base.extend self
  end

  # Public: Default constructor to intialize class properties.
  #
  # args - Hash of propeties and values.
  #
  def initialize(args)
    args.each do |k, v|
      instance_variable_set "@#{k}", v if self.class.props.member?(k)
    end if args.is_a? Hash
  end
end
