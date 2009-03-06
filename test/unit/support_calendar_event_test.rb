require File.dirname(__FILE__) + '/../test_helper'

class SupportCalendarEventTest < Test::Unit::TestCase

  context "new event" do
    setup do
      @event = SupportCalendarEvent.new
    end
  
    should "have default status of 7" do
      assert_equal 7, @event.calendarstatusid
    end
    
    should "have default activitytype of 1" do
      assert_equal 1, @event.activitytype
    end
  end
   
end