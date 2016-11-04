# See the License for the specific language governing permissions and
# limitations under the License.
#

# == BuildsController
#
# Actions for builds resource
class BuildsController < ApplicationController
  def index
    render json: Build.all.to_json
  end

  def create
    return head :unprocessable_entity unless params[:commit].present?
    return head :unprocessable_entity unless params[:project].present?
    
    project = Project.where(name: params[:project]).first

    build = Build.create(project: project,
                         commit: params[:commit],
                         status: 'created')
    build.exec
    
    head :created
  end
end
