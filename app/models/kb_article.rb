class KbArticle < SupportSuiteBase
  has_permission
  
  set_primary_key "kbarticleid"
  set_table_name "swkbarticles"
  
  depends_on :kb_article_data, :attrs => [:contents], :prefix => false, :foreign_key => 'kbarticleid'
  acts_as_list :column => :displayorder
  has_many :kb_category_kb_articles, :foreign_key => 'kbarticleid'
  has_many :kb_categories, :through => :kb_category_kb_articles
  named_scope :published, :conditions => "articlestatus = 'published'", :order => "displayorder ASC"
  named_scope :recent, :limit => 5, :order => "editeddateline"
  
  def created_at
    Time.at(self.dateline)
  end
  
  def updated_at
    self.editeddateline == 0 ? created_at : Time.at(self.editeddateline)
  end
  
  def expires_at
    self.expiry == 0 ? nil : Time.at(self.expiry)
  end
end