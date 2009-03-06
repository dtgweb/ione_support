class SupportTicket < SupportSuiteBase
  has_permission
  
  set_primary_key "ticketid"
  set_table_name "swtickets"
  
  belongs_to :support_user, :foreign_key => :userid
  belongs_to :support_template_group, :foreign_key => :tgroupid
  depends_on :support_ticket_status, :attrs => [:title], :prefix => 'status', :foreign_key => :ticketstatusid
  
  named_scope :open, {:conditions => "swticketstatus.title != 'Closed'", :include => :support_ticket_status}
  named_scope :with_email, lambda { |email| {:conditions => {:email => email} } }
  
  def created_at
    to_timestamp(self.dateline)
  end
  
  def updated_at
    to_timestamp(self.lastactivity)
  end
  
  def last_user_reply
    to_timestamp(self.lastuserreplytime)
  end
  
  def last_staff_reply
    to_timestamp(self.laststaffreplytime)
  end
  
  def due_at
    to_timestamp(self.duetime)
  end
  
end