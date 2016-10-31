# See the License for the specific language governing permissions and
# limitations under the License.
#

# == BuildsController
#
# Actions for builds resource
class BuildsController < ApplicationController
  def create
    return head :unprocessable_entity unless params[:commit].present?
    head :created
  end
end
