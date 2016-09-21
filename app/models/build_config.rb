# See the License for the specific language governing permissions and
# limitations under the License.
#

# == BuildConfig model
class BuildConfig
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :image,  type: String
  field :setup,  type: Set
  field :build,  type: Set
  field :test,   type: Set
  field :deploy, type: Set
end
