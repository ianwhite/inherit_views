require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe FirstController, ' class (a controller with: inherit_views)' do
  it "should inherit_views" do
    FirstController.should be_inherit_views
  end

  it "should have inherit view paths == ['first']" do
    FirstController.inherit_view_paths.should == ['first']
  end
end

describe FirstController do
  it "should inherit_views" do
    @controller.should be_inherit_views
  end

  it "should have inherit view paths == ['first']" do
    @controller.class.inherit_view_paths.should == ['first']
  end
end

describe FirstController, " views" do
  before do
    @view = ActionView::Base.new(@controller.view_paths, {}, @controller)
    @controller.instance_variable_set('@template', @view)
    get :none # to set up request
  end

  it "should render contents of 'first/in_all' when rendering 'first/in_all" do
    @view.render(:file => 'first/in_all').should == '<first />'
  end

  it "should raise error when rendering second/in_first, as 'second' is not in inherit_view_paths" do
    lambda { @view.render(:file => 'second/in_first')}.should raise_error(::ActionView::ActionViewError)
  end

  it "should raise error when rendering first/not_there, as the file 'not_there' is not present" do
    lambda { @view.render(:file => 'first/not_there')}.should raise_error(::ActionView::ActionViewError)
  end
end