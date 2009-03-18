class SupportCustomField < SupportSuiteBase
  set_primary_key "customfieldid"
  set_table_name "swcustomfields"
  
  default_scope :order => 'displayorder ASC'
  
  has_many :support_custom_field_values, :foreign_key => :customfieldid
  belongs_to :support_custom_field_group, :foreign_key => :customfieldgroupid
  
  def field_type
    case fieldtype
      when 1: 'text'
      when 2: 'textarea'
      when 3: 'password'
      when 4: 'radio'
      when 5: 'select'
      when 6: 'multiple-select'
    else 'custom'
    end
  end
end