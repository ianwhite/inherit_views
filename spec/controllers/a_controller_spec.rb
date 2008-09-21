require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe AController, " < TestController; inherit_views" do
  describe "(the class)" do
    it { AController.should be_inherit_views }

    it "should have inherit view paths == ['a']" do
      AController.inherit_view_paths.should == ['a']
    end
  end
  
  describe "(an instance)" do
    integrate_views
  
    it { @controller.should be_inherit_views }

    it "should have inherit view paths == ['a']" do
      @controller.class.inherit_view_paths.should == ['a']
    end
  
    it "GET :in_abc should render a/in_abc" do
      get :in_abc
      response.body.should == 'a:in_abc'
    end

    it "GET :in_a should render a/in_a" do
      get :in_a
      response.body.should == 'a:in_a'
    end

    it "GET :in_ab should render a/in_ab" do
      get :in_ab
      response.body.should == 'a:in_ab'
    end
  end
end