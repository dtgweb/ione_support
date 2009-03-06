class SupportTicketStatus < SupportSuiteBase
  
  set_primary_key "ticketstatusid"
  set_table_name "swticketstatus"
  
  has_many :support_tickets, :foreign_key => :ticketstatusid
  
end