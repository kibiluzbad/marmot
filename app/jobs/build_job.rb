# See the License for the specific language governing permissions and
# limitations under the License.
#

# == BuildJob
class BuildJob < ApplicationJob
  queue_as :default

  def perform(*args)
    arg = args[0]
    ActionCable.server.broadcast('messages', property: 'status',
                                             oldValue: 'test',
                                             newValue: 'test1')
    project = Project.where(name: arg[:project]).first

    build = Build.create(project: project,
                         commit: arg[:commit],
                         status: 'created')
                         
    build.exec
  end
end
