class SupportCustomFieldGroup < SupportSuiteBase
  set_primary_key "customfieldgroupid"
  set_table_name "swcustomfieldgroups"
  
  has_many :support_custom_fields, :foreign_key => :customfieldgroupid
  
  default_scope :order => 'displayorder ASC'
  
  named_scope :teamwork_events, :conditions => {:grouptype => 7}
  named_scope :teamwork_contacts, :conditions => {:grouptype => 6}
  named_scope :teamwork_tasks, :conditions => {:grouptype => 8}
  named_scope :user_registration, :conditions => {:grouptype => 1}
  named_scope :user_groups, :conditions => {:grouptype => 2}
  named_scope :staff_ticket_creation, :conditions => {:grouptype => 3}
  named_scope :user_ticket_creation, :conditions => {:grouptype => 4}
  named_scope :user_and_staff_ticket_creation, :conditions => {:grouptype => 9}
  named_scope :ticket_time_tracking, :conditions => {:grouptype => 5}
  
end