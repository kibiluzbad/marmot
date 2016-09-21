# See the License for the specific language governing permissions and
# limitations under the License.
#

# == ApplicationController
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end
