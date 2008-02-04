require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe FirstController, " < TestController; inherit_views" do
  it { FirstController.should be_inherit_views }

  it "should have inherit view paths == ['first']" do
    FirstController.inherit_view_paths.should == ['first']
  end
end

describe FirstController do
  integrate_views
  
  it { @controller.should be_inherit_views }

  it "should have inherit view paths == ['first']" do
    @controller.class.inherit_view_paths.should == ['first']
  end
  
  it "GET :in_all should render first/in_all" do
    get :in_all
    response.body.should == 'first:in_all'
  end

  it "GET :in_first should render first/in_first" do
    get :in_first
    response.body.should == 'first:in_first'
  end

  it "GET :in_first_and_second should render first/in_first_and_second" do
    get :in_first_and_second
    response.body.should == 'first:in_first_and_second'
  end
  
  it "GET :render_parent should render first/render_parent" do
    get :render_parent
    response.body.should == 'first:render_parent'
  end
  
  it "GET :inherited_template_path should render its contents" do
    get :inherited_template_path
    response.body.should == 'second/in_first_and_second'
  end
end