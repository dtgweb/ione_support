class SupportTask < SupportSuiteBase
  set_primary_key "calendartaskid"
  set_table_name "swcalendartasks"
  
  belongs_to :support_contact, :foreign_key => :contactid
  belongs_to :support_staff, :foreign_key => :staffid
  belongs_to :support_calendar_label, :foreign_key => :calendarlabelid
  belongs_to :support_calendar_status, :foreign_key => :calendarstatusid
  belongs_to :support_calendar_priority, :foreign_key => :calendarpriorityid

  def created_at
    to_timestamp(self.dateline)
  end
  
  def updated_at
    to_timestamp(self.lastupdate)
  end
  
  def due_at
    to_timestamp(self.duedate)
  end
  
  def start_at
    to_timestamp(self.startdate)
  end
  
  def updated_at
    to_timestamp(self.lastupdate)
  end

end