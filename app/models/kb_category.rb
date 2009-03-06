class KbCategory < SupportSuiteBase
  has_permission
  
  set_primary_key "kbcategoryid"
  set_table_name "swkbcategories"
  
  has_many :support_template_group_kb_categories, :foreign_key => 'toassignid', :conditions => "swtgroupassigns.type = 5"
  has_many :support_template_groups, :through => :support_template_group_kb_categories

  acts_as_tree :foreign_key => :parentcategoryid, :order => :displayorder
  
  has_many :kb_category_kb_articles, :foreign_key => 'kbcategoryid'
  has_many :kb_articles, :through => :kb_category_kb_articles
  
  #named_scope :with_group, lambda {|group| {:conditions => ["swtemplategroups.title = :group", {:group => group}], :include => :support_template_groups}}
  
  def created_at
    Time.at(self.dateline)
  end
  
  def updated_at
    self.editeddateline == 0 ? created_at : Time.at(self.editeddateline)
  end
  
end