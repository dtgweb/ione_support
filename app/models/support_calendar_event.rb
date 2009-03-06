class SupportCalendarEvent < SupportSuiteBase
  has_permission
  
  set_primary_key "calendareventid"
  set_table_name "swcalendarevents"
  
  belongs_to :support_staff_owner, :foreign_key => :ownerstaffid, :class_name => "SupportStaff"
  belongs_to :support_staff, :foreign_key => :staffid
  belongs_to :support_calendar_category, :foreign_key => :calendarcategoryid
  belongs_to :support_calendar_label, :foreign_key => :calendarlabelid
  belongs_to :support_calendar_status, :foreign_key => :calendarstatusid
  belongs_to :support_calendar_priority, :foreign_key => :calendarpriorityid
  
  validates_presence_of :subject
  
  before_validation :check_dates
  before_validation :update_staff
  
  named_scope :planned, :conditions => "swcalendarevents.calendarstatusid = 7 or swcalendarevents.calendarstatusid = 0"
  
  def initialize_with_defaults(attrs = nil, &block)
    initialize_without_defaults(attrs) do
      setter = lambda { |key, value| self.send("#{key.to_s}=", value) unless
        !attrs.nil? && attrs.keys.map(&:to_s).include?(key.to_s) }
      setter.call('activitytype', 1)
      setter.call('calendarstatusid', 7)
      yield self if block_given?
    end
  end
  
  alias_method_chain :initialize, :defaults
  
  def activity_type
    self.activitytype == 1 ? "Call" : "Appointment"
  end
  
  def created_at
    to_timestamp(self.dateline)
  end
  
  def updated_at
    to_timestamp(self.lastupdate)
  end
  
  def start_at= (datestring)
    self.startdateline = from_timestamp(Time.parse(datestring))
  end
  
  def end_at= (datestring)
    self.enddateline = from_timestamp(Time.parse(datestring)) unless datestring.blank?
  end
  
  def start_at
    to_timestamp(self.startdateline)
  end
  
  def end_at
    to_timestamp(self.enddateline)
  end
  
  # def validate
  #   errors.add(:enddateline, "End date must be after start date") if self.enddateline < self.startdateline
  # end
  
  protected
    
    def check_dates
      self.enddateline = self.startdateline + 1800 if self.enddateline == 0
    end
    
    def update_staff
      self.support_staff ||= self.support_staff_owner
    end
end