class Permission::KbCategoryPermission < Permission::Base
  
  def method_missing(method, *args)
    if method.to_s.match(DEFAULT_FINDERS)
      object.scoped(:conditions => "categorytype='public'").send(method, *args)
    else
      object.send(method, *args)
    end
  end
end
