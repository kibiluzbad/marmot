# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'git'
# == Respository model
class Repository
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
  
  belongs_to :project
  
  validates :url, presence: true

  field :url, type: String

  def clone(commit)
    @git = Git.clone(url, commit,bare: true, 
                          path: File.expand_path('../../../repos'))
  end

  def get_marmot_file(commit)
    clone(commit) if @git.nil?
    @git.show(commit, 'marmot.yml')
  end
end
