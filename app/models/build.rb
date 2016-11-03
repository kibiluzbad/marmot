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

  METHODS_ALLOWED = ['version', 'image', 'build_steps', 'test_steps', 'setup_steps']

  validates :commit, presence: true

  belongs_to :project
  has_one :build_config

  field :commit, type: String
  field :marmot_file_path, type: String
  field :output, type: Text
  field :status, type: String

  def exec
    self.status = 'started'
    project.repository.clone commit
    config = load_config
    build YAML.load(project.repository.get_marmot_file(commit))
    config.save
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
end
