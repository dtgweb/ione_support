class SupportCalendarCategory < SupportSuiteBase
  set_primary_key "calendarcategoryid"
  set_table_name "swcalendarcategories"
  
  named_scope :events, :conditions => "categorytype = 1"
end