require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe FourthController, " < FirstController; inherit_views 'other'" do
  it { FourthController.should be_inherit_views }

  it "should have inherit view paths == ['fourth', 'other', 'first']" do
    FourthController.inherit_view_paths.should == ['fourth', 'other', 'first']
  end
end

describe FourthController do
  it { @controller.should be_inherit_views }

  it "should have inherit view paths == ['fourth', 'other', 'first']" do
    @controller.class.inherit_view_paths.should == ['fourth', 'other', 'first']
  end
end
