require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe "InheritViews controllers in production mode" do  
  before do
    @controller = ProductionModeController.new
    @other_controller = OtherProductionModeController.new
    # clear the cache each time
    @controller.class.instance_variable_set('@inherited_template_paths_cache', nil) 
    @other_controller.class.instance_variable_set('@inherited_template_paths_cache', nil)
  end

  it "should have inherited_template_paths_cache" do
    @controller.class.should respond_to(:inherited_template_paths_cache)
  end

  it "should cache calls to find_inherited_template_path" do
    @controller.class.inherited_template_paths_cache[['foo/bar', true]] = 'baz'
    @controller.find_inherited_template_path('foo/bar', true).should == 'baz'
  end

  it "should maintain different caches in different classes" do
    @controller.class.inherited_template_paths_cache[['foo/bar', true]] = 'baz'
    @other_controller.class.inherited_template_paths_cache[['foo/bar', true]] = 'BAZ'

    @controller.find_inherited_template_path('foo/bar', true).should == 'baz'
    @other_controller.find_inherited_template_path('foo/bar', true).should == 'BAZ'
  end
end