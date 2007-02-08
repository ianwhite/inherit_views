require File.dirname(__FILE__) + '/../spec_helper'

context "The ThirdController class (a controller inheriting from SecondController)" do
  controller_name :third
  
  specify "should inherit_views" do
    ThirdController.should_inherit_views
  end
  
  specify "should have inherit view paths == ['third', 'second', 'first']" do
    ThirdController.inherit_view_paths.should == ['third', 'second', 'first']
  end
end

context "A ThirdController" do
  controller_name :third
  
  specify "should inherit_views" do
    @controller.should_inherit_views
  end
  
  specify "should have inherit view paths == ['third', 'first']" do
    @controller.inherit_view_paths.should == ['third', 'second', 'first']
  end
end

context "A ThirdController's actions" do
  controller_name :third
  integrate_views
  
  specify "should render first/in_first when GETing :in_first" do
    @controller.should_receive(:render_file_without_inherit_views).with('first/in_first', nil, true, {})
    get :in_first
  end
  
  specify "should render second/in_second when GETing :in_second" do
    @controller.should_receive(:render_file_without_inherit_views).with('second/in_second', nil, true, {})
    get :in_second
  end
  
  specify "should render third/in_third when GETing :in_third" do
    @controller.should_receive(:render_file_without_inherit_views).with('third/in_third', nil, true, {})
    get :in_third
  end
end

context "A ThirdController's views" do
  controller_name :third
  
  setup do
    @view = ActionView::Base.new(@controller.view_paths, {}, @controller)
    @controller.instance_variable_set('@template', @view)
  end
  
  specify "should render contents of 'first/in_first' when rendering 'third/in_first" do
    @view.render(:file => 'third/in_first').should == '<first />'
  end 

  specify "should render contents of 'second/in_second' when rendering 'third/in_second" do
    @view.render(:file => 'third/in_second').should == '<second />'
  end 

  specify "should render contents of 'second/in_first_and_second' when rendering 'third/in_first_and_second" do
    @view.render(:file => 'third/in_first_and_second').should == '<second />'
  end
  
  specify "should render contents of 'third/in_all' when rendering 'third/in_all" do
    @view.render(:file => 'third/in_all').should == '<third />'
  end
  
  specify "should render parent views when <%= render_parent %> is in the view" do
    @view.render(:file => 'third/render_parent').should == "<first />\n<second />\n<third />"
  end
  
  specify "should raise error when rendering fourth/in_third, as 'fourth' is not in inherit_view_paths" do
    lambda { @view.render(:file => 'fourth/in_all')}.should_raise ::ActionView::ActionViewError
  end
  
  specify "should raise error when rendering third/not_there, as the file 'not_there' is not present" do
    lambda { @view.render(:file => 'third/not_there')}.should_raise ::ActionView::ActionViewError
  end
end
  