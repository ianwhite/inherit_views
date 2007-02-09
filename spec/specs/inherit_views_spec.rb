require File.dirname(__FILE__) + '/../spec_helper'
  
context "render_parent in ActionView" do
  
  setup do
    @controller = ThirdController.new
    @view = ActionView::Base.new(@controller.view_paths, {}, @controller)
    @controller.instance_variable_set('@template', @view)
  end
    
  specify "should render the parent view of @current_render when render_parent called" do
    @view.should_receive(:render).with(:file => 'first/in_all', :use_full_path => true)
    @view.instance_variable_set('@current_render', 'second/in_all')
    @view.render_parent
  end
  
  specify "should raise ArgunmentError if called when controller.inherit_views? is false" do
    @controller.stub!(:inherit_views?).and_return(false)
    lambda{ @view.render_parent }.should_raise ArgumentError
  end
  
  specify "should raise InheritedFileNotFound error if there is no parent view" do
    @view.instance_variable_set('@current_render', 'third/in_third')
    lambda{ @view.render_parent }.should_raise Ardes::InheritViews::InheritedFileNotFound
  end
end

context "find_inherited_template_path in ActionController (where inherit_view_paths == ['third', 'second', 'first'])" do
  
  setup do
    @controller = ThirdController.new
    @view = ActionView::Base.new(@controller.view_paths, {}, @controller)
    @controller.instance_variable_set('@template', @view)
  end
  
  specify "should return first/in_first for third/in_first" do
    @controller.find_inherited_template_path('third/in_first').should == 'first/in_first'
  end

  specify "should return second/in_second for third/in_second" do
    @controller.find_inherited_template_path('third/in_second').should == 'second/in_second'
  end

  specify "should return third/in_all for third/in_all" do
    @controller.find_inherited_template_path('third/in_all').should == 'third/in_all'
  end

  specify "should return nil for third/not_there" do
    @controller.find_inherited_template_path('third/not_there').should == nil
  end

  specify "should return nil for fourth/in_third" do
    @controller.find_inherited_template_path('fourth/in_third').should == nil
  end
end

context "InheritViews controllers in production mode" do  
  setup do
    @controller = ProductionModeController.new
    @other_controller = OtherProductionModeController.new
    ProductionModeController.instance_variable_set('@inherited_template_paths_cache', nil) # clear the cache each time
    OtherProductionModeController.instance_variable_set('@inherited_template_paths_cache', nil)
  end
  
  specify "should have inherited_template_paths_cache" do
    ProductionModeController.should_respond_to :inherited_template_paths_cache
  end
  
  specify "should cache calls to find_inherited_template_path" do
    @controller.should_receive(:find_inherited_template_path_without_cache).with('foo/bar', true).once.and_return('baz')
    @controller.find_inherited_template_path('foo/bar', true).should == 'baz'
    @controller.find_inherited_template_path('foo/bar', true).should == 'baz'
  end
  
  specify "should maintain different caches in different classes" do
    @controller.should_receive(:find_inherited_template_path_without_cache).with('foo/bar', true).once.and_return('baz')
    @other_controller.should_receive(:find_inherited_template_path_without_cache).with('foo/bar', true).once.and_return('BAZ')
    
    @controller.find_inherited_template_path('foo/bar', true).should == 'baz'
    @controller.find_inherited_template_path('foo/bar', true).should == 'baz'
    
    @other_controller.find_inherited_template_path('foo/bar', true).should == 'BAZ'
    @other_controller.find_inherited_template_path('foo/bar', true).should == 'BAZ'
    
    ProductionModeController.inherited_template_paths_cache.should == {['foo/bar', true] => 'baz'}
    OtherProductionModeController.inherited_template_paths_cache.should == {['foo/bar', true] => 'BAZ'}
  end
end