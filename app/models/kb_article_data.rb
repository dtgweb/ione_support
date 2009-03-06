class KbArticleData < SupportSuiteBase
  set_primary_key "kbarticledataid"
  set_table_name "swkbarticledata"
  
  belongs_to :kb_article, :foreign_key => 'kbarticleid'
end