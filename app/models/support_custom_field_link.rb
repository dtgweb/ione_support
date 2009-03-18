class SupportCustomFieldLink < SupportSuiteBase
  set_primary_key "customfieldlinkid"
  set_table_name "swcustomfieldlinks"
  
  belongs_to :support_custom_field_group, :foreign_key => :customfieldgroupid
  has_many :support_custom_field_values, :foreign_key => :typeid, :primary_key => :typeid
  
  def link_type
    case linktype
      when 7: "SupportCalendarEvent"
    end
  end
  
  def link
    link_type.constantize.find(typeid)
  end
  
end