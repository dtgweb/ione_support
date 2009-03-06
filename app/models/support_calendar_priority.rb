class SupportCalendarPriority < SupportSuiteBase
  set_primary_key "calendarpriorityid"
  set_table_name "swcalendarpriorities"
  
  has_many :support_tasks, :foreign_key => :calendarpriorityid
  has_many :support_calendar_events, :foreign_key => :calendarpriorityid
end