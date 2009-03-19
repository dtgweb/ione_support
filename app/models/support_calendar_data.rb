class SupportCalendarData < SupportSuiteBase
  set_primary_key "calendardataid"
  set_table_name "swcalendardata"

  named_scope :event_data, :conditions => {:datatype => 2}
  named_scope :task_data, :conditions => {:datatype => 3}  
end