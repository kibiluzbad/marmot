# See the License for the specific language governing permissions and
# limitations under the License.
#

# == Build model
class Build
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  belongs_to :project
  has_one :build_config
  
  field :commit, type: String
end
