class NewsController < StoreController
  #caches_page :show, :index
  around_filter :check_show_fragment, :only => [:show]
  
  make_resourceful do
    actions :index, :show
  end
  
  protected
  
  def current_model_name
    'news_article'
  end
  
  def current_object
    NewsArticle.with_permission(current_user).public.find(params[:id])
  end
  
  def current_objects
    NewsArticle.with_permission(current_user).public
  end
  
end