# See the License for the specific language governing permissions and
# limitations under the License.
#

# == Respository model
class Repository
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  belongs_to :project
  validates :url, presence: true

  field :url, type: String
end
