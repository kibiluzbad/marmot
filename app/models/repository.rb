# See the License for the specific language governing permissions and
# limitations under the License.
#

# == Respository model
class Repository
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :url, type: String
end
