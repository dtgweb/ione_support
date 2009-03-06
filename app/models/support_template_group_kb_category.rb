class SupportTemplateGroupKbCategory < SupportSuiteBase
  set_primary_key "tgroupassignid"
  set_table_name "swtgroupassigns"
  
  belongs_to :kb_category, :foreign_key => 'toassignid'
  belongs_to :support_template_group, :foreign_key => 'tgroupid'
  self.inheritance_column = "type_id"
end