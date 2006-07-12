require File.dirname(__FILE__) + '/test_helper'

class InheritViewsController < ActionController::Base
  inherit_views :first, :second
  self.template_root = File.dirname(__FILE__) + '/views'
  
  def default; end
    
  def first; end
    
  def second; end
  
  def in_all; end
    
  def in_first_and_second; end
end

class InheritViewsTest < Test::Unit::TestCase

  def setup
    @controller = InheritViewsController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  def test_additional_view_paths_array
    assert_equal [:first, :second], @controller.inherit_views_from
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
  
  def test_view_is_not_there
    get :in_none
    assert_response :missing
  end
  
  def test_parent_views_for
    output = @controller.parent_views_for :first do
      assert_equal [:second], @controller.inherit_views_from
      :output
    end
    assert_equal [:first, :second], @controller.inherit_views_from
    assert_equal :output, output 
  end
  
  def test_exclude_views_for
    output = @controller.exclude_views_for :second do
      assert_equal [:first], @controller.inherit_views_from
      :output
    end
    assert_equal [:first, :second], @controller.inherit_views_from
    assert_equal :output, output 
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
  self.inherit_views_from = [:you_can_go_you_own_way]
end

class InheritViewsInheritanceTest < Test::Unit::TestCase
  
  def test_base
    assert_equal [], ActionController::Base.inherit_views_from
  end
  
  def test_parent
    assert_equal [:parent_1, :parent_2], Parent.inherit_views_from
  end
  
  def test_child
    assert_equal [:child, :parent_1, :parent_2], Child.inherit_views_from
  end
  
  def test_grand_child
    assert_equal [:parent_2, :baby, :child, :parent_1], GrandChild.inherit_views_from
  end
  
  def test_fooeyed
    assert_equal [:foo], Fooeyed.inherit_views_from
  end
  
  def test_fooeyed_grand_child
    assert_equal [:foo, :parent_2, :baby, :child, :parent_1], FooeyedGrandChild.inherit_views_from
  end
  
  def test_fooeyed_child
    assert_equal [:bar, :foo], FooeyedChild.inherit_views_from
  end
  
  def test_ignoring_ancestry
    assert_equal [:you_can_go_you_own_way], IgnoringAncestry.inherit_views_from
  end
end