class SupportCalendarEvent < SupportSuiteBase
  has_permission
  
  set_primary_key "calendareventid"
  set_table_name "swcalendarevents"
  
  belongs_to :support_staff_owner, :foreign_key => :ownerstaffid, :class_name => "SupportStaff"
  belongs_to :support_staff, :foreign_key => :staffid
  belongs_to :support_calendar_category, :foreign_key => :calendarcategoryid
  belongs_to :support_calendar_label, :foreign_key => :calendarlabelid
  belongs_to :support_calendar_status, :foreign_key => :calendarstatusid
  
  has_dependency :support_calendar_data, :foreign_key => :typeid, :conditions => {:datatype => 2}, :attrs => [:contents, :datatype], :prefix => "notes", :class_name => "SupportCalendarData"
  
  has_many :support_custom_field_links, :foreign_key => :typeid, :conditions => {:linktype => 7}
  has_many :support_custom_field_groups, :finder_sql => "SELECT swcustomfieldgroups.* FROM swcustomfieldgroups where grouptype = 7"
  has_many :support_custom_fields, :finder_sql => "SELECT swcustomfields.* FROM swcustomfields INNER JOIN swcustomfieldgroups ON swcustomfieldgroups.customfieldgroupid = swcustomfields.customfieldgroupid WHERE swcustomfieldgroups.grouptype = 7"
  has_many :support_custom_field_values, :finder_sql => 'SELECT swcustomfieldvalues.* FROM swcustomfieldvalues INNER JOIN swcustomfields ON swcustomfields.customfieldid = swcustomfieldvalues.customfieldid INNER JOIN swcustomfieldgroups ON swcustomfieldgroups.customfieldgroupid = swcustomfields.customfieldgroupid INNER JOIN swcalendarevents ON swcalendarevents.calendareventid = swcustomfieldvalues.typeid WHERE swcustomfieldgroups.grouptype = 7 and swcalendarevents.calendareventid = #{id}', :foreign_key => :typeid
  
  accepts_nested_attributes_for :support_custom_field_links
  accepts_nested_attributes_for :support_custom_field_values
  accepts_nested_attributes_for :support_calendar_data
  
  def support_custom_field_groups_with_new_record
    new_record? ? SupportCustomFieldGroup.scoped(:conditions => {:grouptype => 7}) : support_custom_field_groups_without_new_record
  end
  
  alias_method_chain :support_custom_field_groups, :new_record
  
  # make sure all attributes are correctly filled out
  validates_presence_of :subject
  before_validation :check_dates
  before_validation :update_staff
  before_create :set_dateline
  before_save :set_lastupdate
  
  named_scope :planned, :conditions => "swcalendarevents.calendarstatusid = 7 or swcalendarevents.calendarstatusid = 0"
  named_scope :public, :conditions => {:eventtype => 'public'}
    
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
  
  def owner
    support_staff_owner ? support_staff_owner : support_staff
  end
  
  def to_ics
    event = Icalendar::Event.new
    event_start = start_at
    event_start.ical_params = {"TZID", Time.zone.tzinfo.name} if event_start
    event_end = end_at
    event_end.ical_params = {"TZID", Time.zone.tzinfo.name} if event_end
    event.start = event_start
    event.end = event_end
    event.summary = subject
    event.url = SUPPORT_URL + "/staff/index.php?_m=teamwork&_a=editevent&calendareventid=#{calendareventid}"
    event.klass = eventtype.upcase
    # http://www.kanzaki.com/docs/ical/organizer.html
    event.organizer = "MAILTO:#{owner.email}" if owner
    # http://www.kanzaki.com/docs/ical/categories.html
    event.add_category support_calendar_category.title if support_calendar_category
    event.alarm do
      description "Event reminder"
      trigger "-PT15M" # 15 minutes before
    end
    event
  end
    
  def self.to_ics(events)
    icalendar = Icalendar::Calendar.new
    events.each {|event| icalendar.add_event(event.to_ics) }
    icalendar.to_ical
  end
  
  # def validate
  #   errors.add(:enddateline, "End date must be after start date") if self.enddateline < self.startdateline
  # end
  
  protected
    
    def set_dateline
      puts 'set dateline'
      self.dateline = from_timestamp(Time.now)
    end
    
    def set_lastupdate
      puts 'set lastupdate'
      self.lastupdate = from_timestamp(Time.now)
    end
    
    def check_dates
      self.enddateline = self.startdateline + 1800 if self.enddateline == 0
      self.duration = self.enddateline - self.startdateline
    end
    
    def update_staff
      self.support_staff ||= self.support_staff_owner
    end
end