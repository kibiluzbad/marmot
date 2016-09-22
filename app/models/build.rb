# See the License for the specific language governing permissions and
# limitations under the License.
#

# == Build model
class Build
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  validates :commit, presence: true

  belongs_to :project
  has_one :build_config

  field :commit, type: String
  field :marmot_file_path, type: String
  field :output, type: Text

  def exec
    load_config
  end

  protected

  def load_config
    BuildConfig.create(build: self)
  end
end
