class SupportCustomFieldLink < SupportSuiteBase
  set_primary_key "customfieldlinkid"
  set_table_name "swcustomfieldlinks"
  
  belongs_to :support_custom_field_group, :foreign_key => :customfieldgroupid

  accepts_nested_attributes_for :support_custom_field_group
  
  def link_type
    case linktype
      when 7: "SupportCalendarEvent"
      when 6: "SupportContact"
    end
  end
  
  def link
    link_type.constantize.find(typeid)
  end
  
end