class SupportContact < SupportSuiteBase
  set_primary_key "contactid"
  set_table_name "swcontacts"
  
  belongs_to :support_staff, :foreign_key => :staffid
  belongs_to :support_calendar_category, :foreign_key => :calendarcategoryid

  has_many :support_custom_field_links, :foreign_key => :typeid, :conditions => {:linktype => 6}
  has_many :support_custom_field_groups, :through => :support_custom_field_links
  
  def support_user
    SupportUser.with_email(email_list).first
  end
  
  def updated_at
    to_timestamp(self.lastupdate)
  end
  
  def email_list
    [email1address, email2address, email3address].select {|email| !email.nil? && !email.blank? }.uniq
  end
  
  def support_tickets
    SupportTicket.with_email((email_list + (support_user ? support_user.email_list : [])).uniq)
  end
  
  protected
  
    def update_timestamp
      t = self.class.default_timezone == :utc ? Time.now.utc : Time.now
      self.lastupdate = from_timestamp(t)
    end
  
end