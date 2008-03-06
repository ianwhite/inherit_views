require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe ThirdController, " < SecondController" do
  it { ThirdController.should be_inherit_views }

  it "should have inherit view paths == ['third', 'second', 'first']" do
    ThirdController.inherit_view_paths.should == ['third', 'second', 'first']
  end
end

describe ThirdController do
  integrate_views
  
  it { @controller.should be_inherit_views }

  it "should have inherit view paths == ['third', 'first']" do
    @controller.inherit_view_paths.should == ['third', 'second', 'first']
  end
  
  it "GET :in_first should render first/in_first" do
    get :in_first
    response.body.should == 'first:in_first'
  end
  
  it "GET :in_first_and_second should render second/in_first_and_second" do
    get :in_first_and_second
    response.body.should == 'second:in_first_and_second'
  end
  
  it "GET :in_second should render second/in_second" do
    get :in_second
    response.body.should == 'second:in_second'
  end

  it "GET :in_all should render third/in_all" do
    get :in_all
    response.body.should == 'third:in_all'
  end
  
  it "GET :in_third shoudl render third/in_third" do
    get :in_third
    response.body.should == 'third:in_third'
  end

  it "GET :render_parent should render first/render_parent inside second/render_parent inside third/render_parent" do
    get :render_parent
    response.body.should == "first:render_parent\nsecond:render_parent\nthird:render_parent"
  end
  
  it "GET :partial should render second/partial & third/_partial" do
    get :partial
    response.body.should == "second:partial\nthird:_partial"
  end
end