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
    repos_path = File.expand_path('repos')
    repo_path = File.join(repos_path, commit)
    @git = Git.open(repo_path) if FileTest.exist?(repo_path)
    @git = Git.clone(url, commit, path: repos_path) if @git.nil?
  end

  def get_marmot_file(commit)
    clone(commit) if @git.nil?
    @git.show(commit, 'marmot.yml')
  end

  def get_path(commit)
    repos_path = File.expand_path('repos')
    File.join(repos_path, commit)
  end
end
