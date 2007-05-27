require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe SecondController, " class (a controller with: inherit_views 'first')" do
  it "should inherit_views" do
    SecondController.should be_inherit_views
  end

  it "should have inherit view paths == ['second', 'first']" do
    SecondController.inherit_view_paths.should == ['second', 'first']
  end
end

describe SecondController do
  it "should inherit_views" do
    @controller.should be_inherit_views
  end

  it "should have inherit view paths == ['second', 'first']" do
    @controller.inherit_view_paths.should == ['second', 'first']
  end
end

describe SecondController, " actions" do
  integrate_views

  it "should render first/in_first when GETing :in_first" do
    @controller.should_receive(:render_file_without_inherit_views).with('first/in_first', nil, true, {})
    get :in_first
  end

  it "should render second/in_second when GETing :in_second" do
    @controller.should_receive(:render_file_without_inherit_views).with('second/in_second', nil, true, {})
    get :in_second
  end
end

describe SecondController, " views" do
  before do
    @view = ActionView::Base.new(@controller.view_paths, {}, @controller)
    @controller.instance_variable_set('@template', @view)
    get :none # set up request
  end

  it "should render contents of 'first/in_first' when rendering 'second/in_first" do
    @view.render(:file => 'second/in_first').should == '<first />'
  end 

  it "should render contents of 'second/in_first_and_second' when rendering 'second/in_first_and_second" do
    @view.render(:file => 'second/in_first_and_second').should == '<second />'
  end

  it "should render contents of 'second/in_all' when rendering 'second/in_all" do
    @view.render(:file => 'second/in_all').should == '<second />'
  end

  it "should render parent views when <%= render_parent %> is in the view" do
    @view.render(:file => 'second/render_parent').should == "<first />\n<second />"
  end

  it "should raise error when rendering third/in_second, as 'third' is not in inherit_view_paths" do
    lambda { @view.render(:file => 'third/in_second')}.should raise_error(::ActionView::ActionViewError)
  end

  it "should raise error when rendering second/not_there, as the file 'not_there' is not present" do
    lambda { @view.render(:file => 'second/not_there')}.should raise_error(::ActionView::ActionViewError)
  end
end