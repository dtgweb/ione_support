class KbCategoryKbArticle < SupportSuiteBase
  set_primary_key "kbarticlelinkid"
  set_table_name "swkbarticlelinks"
  
  belongs_to :kb_article, :foreign_key => :kbarticleid
  belongs_to :kb_category, :foreign_key => :kbcategoryid
end