require File.dirname(__FILE__) + '/test_helper'

class InheritViewsController < ActionController::Base
  inherit_views 'first', :second, :third
    
  self.template_root = File.join(File.dirname(__FILE__), 'views')

  def default; end
    
  def first; end
    
  def second; end
  
  def in_all; end
    
  def in_first_and_second; end

  def nested; end
  
  def rescue_action(exception); super(exception); raise exception; end
end

class InheritViewsTest < Test::Unit::TestCase

  def setup
    @controller = InheritViewsController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  def test_inherit_view_paths_array
    assert_equal ['first', 'second', 'third'], @controller.inherit_view_paths
  end
  
  def test_pick_inherited_template_path
    get :default # to load @template
    
    assert_equal 'inherit_views/default',         @controller.pick_inherited_template_path('inherit_views/default')
    assert_equal 'inherit_views/default.rhtml',   @controller.pick_inherited_template_path('inherit_views/default.rhtml')
    assert_equal 'first/first',                   @controller.pick_inherited_template_path('inherit_views/first')
    assert_equal 'second/second',                 @controller.pick_inherited_template_path('inherit_views/second')
    assert_equal 'inherit_views/in_all',          @controller.pick_inherited_template_path('inherit_views/in_all')
    assert_equal 'first/in_first_and_second',     @controller.pick_inherited_template_path('inherit_views/in_first_and_second')

    assert_equal 'inherit_views/default_rjs',     @controller.pick_inherited_template_path('inherit_views/default_rjs')    
    assert_equal 'inherit_views/default_rjs.rjs', @controller.pick_inherited_template_path('inherit_views/default_rjs.rjs')
    assert_equal 'second/second_rjs',             @controller.pick_inherited_template_path('inherit_views/second_rjs')
    assert_equal 'second/second_rjs.rjs',         @controller.pick_inherited_template_path('inherit_views/second_rjs.rjs')
  end
  
  def test_action_exists_in_default_views
    get :default
    assert_response :success
  end
  
  def test_action_exists_in_first_views
    get :first
    assert_response :success
  end
  
  def test_action_exists_in_second_views
    get :second
    assert_response :success
  end
  
  def test_view_is_fetched_from_default_if_it_exists_in_all
    get :in_all
    assert_tag :tag => 'default'
  end
  
  def test_view_is_fetched_from_first_if_it_exists_in_first_and_second
    get :in_first_and_second
    assert_tag :tag => 'first'
  end
  
  def test_nested_views
    get :nested
    assert_tag :tag => 'default'
    assert_tag :tag => 'first'
    assert_tag :tag => 'second'
  end
  
  def test_view_is_not_there
    assert_raises(::ActionController::UnknownAction) { get :in_none }
  end
  
  def test_bad_template_specification
    assert_raises(::ActionView::TemplateError) { get :bad_template }
  end
  
  def test_parent_views_for
    output = @controller.parent_views_for :first do
      assert_equal ['second', 'third'], @controller.inherit_view_paths
      assert_equal true, @controller.instance_eval {@inherit_views_exclude_default}
      :output
    end
    assert_equal ['first', 'second', 'third'], @controller.inherit_view_paths
    assert_equal nil, @controller.instance_eval {@inherit_views_exclude_default}
    assert_equal :output, output 
  end
end

#
# Complex paths test
#

class ComplexPathController < ActionController::Base
  inherit_views 'complex_path/one', 'complex_path/two'
  
  self.template_root = File.join(File.dirname(__FILE__), 'views')

  def index; end
  def one; end
  def two; end
  
  def rescue_action(exception); super(exception); raise exception; end
end

class ComplexPathTest < Test::Unit::TestCase

  def setup
    @controller = ComplexPathController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  def test_index
    get :index
    assert_tag :tag => 'index'
  end
  
  def test_one
    get :one
    assert_tag :tag => 'one'
  end
  
  def test_two
    get :two
    assert_tag :tag => 'two'
  end
end

#
# parent views test
#

class ParentViewsController < ActionController::Base
  inherit_views 'parent_views/inherited'
  self.template_root = File.join(File.dirname(__FILE__), 'views')

  def index; end
  
  def rescue_action(exception); super(exception); raise exception; end
end

class ParentViewsTest < Test::Unit::TestCase

  def setup
    @controller = ParentViewsController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  def test_index
    get :index
    assert_tag :tag => 'index_in_parent_views'
    assert_tag :tag => 'index_in_inherited'
  end
  
  def test_not_there
    assert_raises (ActionView::TemplateError) { get :not_there }
  end
end


#
# Inheritance of views testing
# 

class Parent < ActionController::Base
  inherit_views :parent_1, :parent_2
end

class Child < Parent
  inherit_views
end

class GrandChild < Child
  inherit_views :parent_2, :baby
end

module FooAct
  def foo_view
    inherit_views :foo
  end
end
ActionController::Base.class_eval { extend FooAct }

class FooeyedGrandChild < GrandChild
  foo_view
end

class Fooeyed < ActionController::Base
  foo_view
end

class FooeyedChild < Fooeyed
  inherit_views :bar
end

class IgnoringAncestry < FooeyedGrandChild
  self.inherit_view_paths = ['you_can_go_you_own_way']
end

class InheritViewsInheritanceTest < Test::Unit::TestCase
  
  def test_base
    assert_raises(NoMethodError) { ActionController::Base.inherit_view_paths }
    assert_equal nil, ActionController::Base.has_inheritable_views
  end
  
  def test_parent
    assert_equal ['parent_1', 'parent_2'], Parent.inherit_view_paths
    assert_equal true, Parent.has_inheritable_views
  end
  
  def test_child
    assert_equal ['child', 'parent_1', 'parent_2'], Child.inherit_view_paths
    assert_equal true, Child.has_inheritable_views
  end
  
  def test_grand_child
    assert_equal ['parent_2', 'baby', 'child', 'parent_1'], GrandChild.inherit_view_paths
    assert_equal true, GrandChild.has_inheritable_views
  end
  
  def test_fooeyed
    assert_equal ['foo'], Fooeyed.inherit_view_paths
    assert_equal true, Fooeyed.has_inheritable_views
  end
  
  def test_fooeyed_grand_child
    assert_equal ['foo', 'parent_2', 'baby', 'child', 'parent_1'], FooeyedGrandChild.inherit_view_paths
    assert_equal true, FooeyedGrandChild.has_inheritable_views
  end
  
  def test_fooeyed_child
    assert_equal ['bar', 'foo'], FooeyedChild.inherit_view_paths
    assert_equal true, FooeyedChild.has_inheritable_views
  end
  
  def test_own_ancestry
    assert_equal ['you_can_go_you_own_way'], IgnoringAncestry.inherit_view_paths
    assert_equal true, IgnoringAncestry.has_inheritable_views
  end
  
end