class SupportTicketsController < ApplicationController

  make_ext_resourceful do
    actions :show, :index
  end
  
  protected
  
  def options_for_json
    {
      :filters => [],
      :only => ['email', 'subject', 'lastreplier', 'fullname', 'ticketid'],
      :methods => ['created_at', 'due_at'],
      :include => {:support_ticket_status => {:only => :title}},
      :extra => 'support_ticket_status.title',
      :overrides => [
      	['support_ticket_status.title', {:header => 'Status', :hidden => false, :width => 15}],
      	['fullname', {:header => 'Name', :hidden => false}],
      	['email', {:hidden => false}],
      	['subject', {:hidden => false}],
      	['lastreplier', {:header => 'Last Replier', :hidden => false}],
      	['created_at', {:header => 'Date', :hidden => false, :renderer => "Ext.util.Format.dateRenderer('m/d/Y g:i A T')"}],
      	['due_at', {:header => 'Due', :hidden => false, :renderer => "Ext.util.Format.dateRenderer('m/d/Y g:i A T')"}]
      ]
    }
  end
  
  def current_model_with_permission
    current_model_without_permission.with_permission(current_user)
  end
  
  alias_method_chain :current_model, :permission
  
  def current_object_with_permission
    current_object_without_permission.with_permission(current_user)
  end
  
  alias_method_chain :current_object, :permission
    
  def current_objects
    @current_objects ||= paginate_current_objects :include => {:support_ticket_status => [:title]}, :sort => 'support_ticket[dateline]', :dir => 'DESC'
  end
end
