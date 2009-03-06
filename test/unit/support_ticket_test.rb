require File.dirname(__FILE__) + '/../test_helper'
require 'user'

class SupportTicketTest < Test::Unit::TestCase
  def setup
    Factory(:support_ticket)
    @ticket = Factory(:support_ticket, :email => 'test@test.com')
  end

  should "be scoped by email" do
    assert_equal [@ticket], SupportTicket.with_email('test@test.com') 
  end
  
end
