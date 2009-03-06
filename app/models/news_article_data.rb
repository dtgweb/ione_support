class NewsArticleData < SupportSuiteBase
  set_primary_key "newsdataid"
  set_table_name "swnewsdata"
  
  belongs_to :news_article, :foreign_key => 'newsid'
end