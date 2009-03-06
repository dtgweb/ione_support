class SupportCalendarStatus < SupportSuiteBase
  set_primary_key "calendarstatusid"
  set_table_name "swcalendarstatus"
  
  has_many :support_tasks, :foreign_key => :calendarstatusid
  has_many :support_calendar_events, :foreign_key => :calendarstatusid
  
  named_scope :events, :conditions => "statustype = 2"
end