class SupportCustomFieldValue < SupportSuiteBase
  set_primary_key "customfieldvalueid"
  set_table_name "swcustomfieldvalues"
  
  belongs_to :support_custom_field, :foreign_key => :customfieldid
  belongs_to :support_custom_field_link, :foreign_key => :typeid, :primary_key => :typeid
end