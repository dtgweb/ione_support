class SupportStaff < SupportSuiteBase
  set_primary_key "staffid"
  set_table_name "swstaff"
  
  has_many :support_contacts, :foreign_key => :staffid
  has_many :support_tasks, :foreign_key => :staffid
  has_many :support_calendar_events, :foreign_key => :staffid
end