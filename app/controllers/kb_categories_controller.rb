class KbCategoriesController < StoreController
  #around_filter :check_show_fragment, :only => [:show]
  
  make_resourceful do
    actions :show, :index
  end
  
  protected
  
  def recent_articles
    KbArticle.with_permission(current_user).recent
  end
  
  def current_objects
    KbCategory.with_permission(current_user).find(:all, :conditions => {:parentcategoryid => 0})
  end
  
  def current_model
    KbCategory.with_permission(current_user)
  end
  
  helper_method :recent_articles
end