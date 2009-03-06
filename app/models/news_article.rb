class NewsArticle < SupportSuiteBase
  has_permission
  set_primary_key "newsid"
  set_table_name "swnews"
  
  depends_on :news_article_data, :attrs => [:contents], :prefix => false, :foreign_key => 'newsid'
  #has_many :support_template_group_news_articles, :foreign_key => 'toassignid', :conditions => {:type => 5}
  #has_many :support_template_groups, :through => :support_template_group_news_articles
  belongs_to :support_template_group, :foreign_key => 'tgroupid'
  named_scope :public, :conditions => ["newstype = 'public' AND (expiry = 0 OR expiry > :now)", {:now => Time.now.to_i}], :order => "dateline DESC"
  named_scope :with_group, lambda {|group| {:conditions => ["swtemplategroups.title = :group", {:group => group}], :include => :support_template_group}}
  
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