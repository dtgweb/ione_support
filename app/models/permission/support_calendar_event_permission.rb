class Permission::SupportCalendarEventPermission < Permission::Base
  
  def can_view?
    !user.support_staff.nil?
  end
  
end
