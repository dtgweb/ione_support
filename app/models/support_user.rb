class SupportUser < SupportSuiteBase
  set_primary_key "userid"
  set_table_name "swusers"
  
  has_many :support_tickets, :foreign_key => 'userid'
  has_many :support_user_emails, :foreign_key => 'userid'
  
  named_scope :with_email, lambda { |email| {:conditions => ["`swuseremails`.`email` in (?)", email], :include => :support_user_emails} }
  
  def updated_at
    to_timestamp(self.dateline)
  end
  
  def email_list
    support_user_emails.collect {|support_user_email| support_user_email.email }.select {|email| !email.nil? && !email.blank? }
  end
  
  def support_tickets
    SupportTicket.with_email(email_list)
  end
  
  protected
  
    def update_timestamp
      t = self.class.default_timezone == :utc ? Time.now.utc : Time.now
      self.dateline = from_timestamp(t)
    end
end