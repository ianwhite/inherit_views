require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe ThirdController, " class (a controller inheriting from SecondController)" do
  it "should inherit_views" do
    ThirdController.should be_inherit_views
  end

  it "should have inherit view paths == ['third', 'second', 'first']" do
    ThirdController.inherit_view_paths.should == ['third', 'second', 'first']
  end
end

describe ThirdController do
  it "should inherit_views" do
    @controller.should be_inherit_views
  end

  it "should have inherit view paths == ['third', 'first']" do
    @controller.inherit_view_paths.should == ['third', 'second', 'first']
  end
end

describe ThirdController, " actions" do
  integrate_views

  it "should render first/in_first when GETing :in_first" do
    @controller.should_receive(:render_for_file_without_inherit_views).with('first/in_first', nil, true, {})
    get :in_first
  end

  it "should render second/in_second when GETing :in_second" do
    @controller.should_receive(:render_for_file_without_inherit_views).with('second/in_second', nil, true, {})
    get :in_second
  end

  it "should render third/in_third when GETing :in_third" do
    @controller.should_receive(:render_for_file_without_inherit_views).with('third/in_third', nil, true, {})
    get :in_third
  end
end

describe ThirdController, " views" do
  before do
    @view = ActionView::Base.new(@controller.view_paths, {}, @controller)
    @controller.instance_variable_set('@template', @view)
    @view.stub!(:template_format).and_return(:html)
  end

  it "should render contents of 'first/in_first' when rendering 'third/in_first" do
    @view.render(:file => 'third/in_first').should == '<first />'
  end 

  it "should render contents of 'second/in_second' when rendering 'third/in_second" do
    @view.render(:file => 'third/in_second').should == '<second />'
  end 

  it "should render contents of 'second/in_first_and_second' when rendering 'third/in_first_and_second" do
    @view.render(:file => 'third/in_first_and_second').should == '<second />'
  end

  it "should render contents of 'third/in_all' when rendering 'third/in_all" do
    @view.render(:file => 'third/in_all').should == '<third />'
  end

  it "should render parent views when <%= render_parent %> is in the view" do
    @view.render(:file => 'third/render_parent').should == "<first />\n<second />\n<third />"
  end

  it "should raise error when rendering fourth/in_third, as 'fourth' is not in inherit_view_paths" do
    lambda { @view.render(:file => 'fourth/in_all')}.should raise_error(::ActionView::ActionViewError)
  end

  it "should raise error when rendering third/not_there, as the file 'not_there' is not present" do
    lambda { @view.render(:file => 'third/not_there')}.should raise_error(::ActionView::ActionViewError)
  end
end