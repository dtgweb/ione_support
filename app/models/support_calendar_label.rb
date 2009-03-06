class SupportCalendarLabel < SupportSuiteBase
  set_primary_key "calendarlabelid"
  set_table_name "swcalendarlabels"
  
  has_many :support_calendar_events, :foreign_key => :calendarlabelid
  has_many :support_tasks, :foreign_key => :calendarlabelid
  
  named_scope :events, :conditions => "labeltype = 2"
end