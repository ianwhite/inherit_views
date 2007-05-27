require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe 'ActionView#render_parent for ThirdController' do
  controller_name :third
  
  before do
    @view = ActionView::Base.new(@controller.view_paths, {}, @controller)
    @controller.instance_variable_set('@template', @view)
    get :none # set up request
  end
  
  it "should render the parent view of @current_render when render_parent called" do
    @view.should_receive(:render).with(:file => 'first/in_all', :use_full_path => true)
    @view.instance_variable_set('@current_render', 'second/in_all')
    @view.render_parent
  end

  it "should raise ArgunmentError if called when controller.inherit_views? is false" do
    @controller.stub!(:inherit_views?).and_return(false)
    lambda{ @view.render_parent }.should raise_error(ArgumentError)
  end

  it "should raise InheritedFileNotFound error if there is no parent view" do
    @view.instance_variable_set('@current_render', 'third/in_third')
    lambda{ @view.render_parent }.should raise_error(Ardes::InheritViews::InheritedFileNotFound)
  end
end
  
describe "ActionView#inherited_template_path for ThirdController" do    
  controller_name :third
  
  before do
    @view = ActionView::Base.new(@controller.view_paths, {}, @controller)
    @controller.instance_variable_set('@template', @view)
    get :none # set up request
  end

  it "should return third/in_second when called with second/in_second (without controller class)" do
    @view.inherited_template_path('third/in_second').should == 'second/in_second'
  end
  
  it "should return nil when called with third/in_second (with controller class specified as FirstController)" do
    @view.inherited_template_path('third/in_second', FirstController).should == nil
  end
end
  
describe "ActionController#find_inherited_template_path for ThirdController" do
  controller_name :third
  
  before do
    @view = ActionView::Base.new(@controller.view_paths, {}, @controller)
    @controller.instance_variable_set('@template', @view)
    get :none # set up request
  end

  it "should return first/in_first for third/in_first" do
    @controller.find_inherited_template_path('third/in_first').should == 'first/in_first'
  end

  it "should return second/in_second for third/in_second" do
    @controller.find_inherited_template_path('third/in_second').should == 'second/in_second'
  end

  it "should return third/in_all for third/in_all" do
    @controller.find_inherited_template_path('third/in_all').should == 'third/in_all'
  end

  it "should return nil for third/not_there" do
    @controller.find_inherited_template_path('third/not_there').should == nil
  end

  it "should return nil for fourth/in_third" do
    @controller.find_inherited_template_path('fourth/in_third').should == nil
  end
end

describe "InheritViews controllers in production mode" do  
  controller_name :production_mode
  
  before do
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