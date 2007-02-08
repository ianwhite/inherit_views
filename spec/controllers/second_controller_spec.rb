require File.dirname(__FILE__) + '/../spec_helper'

context "The SecondController class (a controller with: inherit_views 'first')" do
  controller_name :second
  
  specify "should inherit_views" do
    SecondController.should_inherit_views
  end
  
  specify "should have inherit view paths == ['second', 'first']" do
    SecondController.inherit_view_paths.should == ['second', 'first']
  end
end

context "A SecondController" do
  controller_name :second
  
  specify "should inherit_views" do
    @controller.should_inherit_views
  end
  
  specify "should have inherit view paths == ['second', 'first']" do
    @controller.inherit_view_paths.should == ['second', 'first']
  end
end

context "A SecondController's actions" do
  controller_name :second
  integrate_views
  
  specify "should render first/in_first when GETing :in_first" do
    @controller.should_receive(:render_file_without_inherit_views).with('first/in_first', nil, true, {})
    get :in_first
  end
  
  specify "should render second/in_second when GETing :in_second" do
    @controller.should_receive(:render_file_without_inherit_views).with('second/in_second', nil, true, {})
    get :in_second
  end
end

context "A SecondController's views" do
  controller_name :second
  
  setup do
    @view = ActionView::Base.new(@controller.view_paths, {}, @controller)
    @controller.instance_variable_set('@template', @view)
  end
  
  specify "should render contents of 'first/in_first' when rendering 'second/in_first" do
    @view.render(:file => 'second/in_first').should == '<first />'
  end 

  specify "should render contents of 'second/in_first_and_second' when rendering 'second/in_first_and_second" do
    @view.render(:file => 'second/in_first_and_second').should == '<second />'
  end
  
  specify "should render contents of 'second/in_all' when rendering 'second/in_all" do
    @view.render(:file => 'second/in_all').should == '<second />'
  end
  
  specify "should render parent views when <%= render_parent %> is in the view" do
    @view.render(:file => 'second/render_parent').should == "<first />\n<second />"
  end
  
  specify "should raise error when rendering third/in_second, as 'third' is not in inherit_view_paths" do
    lambda { @view.render(:file => 'third/in_second')}.should_raise ::ActionView::ActionViewError
  end
  
  specify "should raise error when rendering second/not_there, as the file 'not_there' is not present" do
    lambda { @view.render(:file => 'second/not_there')}.should_raise ::ActionView::ActionViewError
  end
end