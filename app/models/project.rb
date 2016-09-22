# See the License for the specific language governing permissions and
# limitations under the License.
#

# == Project model
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
