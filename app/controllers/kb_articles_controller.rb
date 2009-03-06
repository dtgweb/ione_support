class KbArticlesController < StoreController
  #around_filter :check_show_fragment, :only => [:show]
  
  make_resourceful do
    actions :index, :show
  end
  
end