require File.dirname(__FILE__) + '/../spec_helper'

context "The FirstController class (a controller with: inherit_views) " do
  controller_name :first
  
  specify "should inherit_views" do
    FirstController.should_inherit_views
  end
  
  specify "should have inherit view paths == ['first']" do
    FirstController.inherit_view_paths.should == ['first']
  end
end

context "A new FirstController" do
  controller_name :first
  
  specify "should inherit_views" do
    @controller.should_inherit_views
  end
  
  specify "should have inherit view paths == ['first']" do
    @controller.inherit_view_paths.should == ['first']
  end
end

context "A FirstController's views" do
  controller_name :first
  
  setup do
    @view = ActionView::Base.new(@controller.view_paths, {}, @controller)
    @controller.instance_variable_set('@template', @view)
  end
  
  specify "should render contents of 'first/in_all' when rendering 'first/in_all" do
    @view.render(:file => 'first/in_all').should == '<first />'
  end
  
  specify "should raise error when rendering second/in_first, as 'second' is not in inherit_view_paths" do
    lambda { @view.render(:file => 'second/in_first')}.should_raise ::ActionView::ActionViewError
  end
  
  specify "should raise error when rendering first/not_there, as the file 'not_there' is not present" do
    lambda { @view.render(:file => 'first/not_there')}.should_raise ::ActionView::ActionViewError
  end
end