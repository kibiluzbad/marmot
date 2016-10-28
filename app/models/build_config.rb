# See the License for the specific language governing permissions and
# limitations under the License.
#

# == BuildConfig model
class BuildConfig
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  belongs_to :build
  
  field :image,       type: String
  field :language,    type: String
  field :version,     type: String
  field :setup_steps,       type: Set
  field :build_steps, type: Set
  field :test_steps,        type: Set
  field :deploy,      type: Set

  def method_missing(method_name, *args, &block)
    if /#{language}_version/ =~ method_name
      if args
        self.version ||= args[0]
      else
        self.version
      end
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    /#{language}_version/ =~ method_name || super
  end

end
