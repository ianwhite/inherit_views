require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Mailer do
  before :all do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
  end
  
  before :each do
    Mailer.deliver_email
    @deliveries = ActionMailer::Base.deliveries
  end
  
  it "should deliver email" do
    @deliveries.size.should == 1
  end
end