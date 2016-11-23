# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'yaml'
require 'build/dsl'

# == Build model
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

  def exec
    started
    project.repository.clone commit
    config = load_config
    build YAML.load(project.repository.get_marmot_file(commit))
    config.save
    save
  end

  def started
    self.status = 'started'
    broadcast_message property: :status,
                      value: status
  end

  def running
    self.status = 'running'
    broadcast_message property: :status,
                      value: status
  end

  def success
    self.status = 'success'
    broadcast_message property: :status,
                      value: status
  end

  def failed(message = nil)
    self.status = 'failed'
    append_to_log message
    broadcast_message property: :status,
                      value: status
  end

  def append_to_log(message)
    self.output = '' if output.nil?
    self.output += message unless message.nil?
    broadcast_message property: :output,
                      value: message
  end

  def method_missing(method_name, *args, &block)
    if METHODS_ALLOWED.include? method_name.to_s
      build_config[method_name] = args.first
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    METHODS_ALLOWED.include?(method_name.to_s) || super
  end

  protected

  def load_config
    BuildConfig.create(build: self, language: project.language)
  end

  def broadcast_message(args)
    ActionCable.server.broadcast 'messages',
                                 property: args[:property],
                                 newValue: args[:value]
  end
end
