class SupportTemplateGroup < SupportSuiteBase
  set_primary_key "tgroupid"
  set_table_name "swtemplategroups"

  has_many :news_articles, :foreign_key => 'newsid'
end