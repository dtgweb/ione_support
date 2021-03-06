class SupportCalendarEventsController < ApplicationController

  before_filter :login_required
  
  make_ext_resourceful do
    actions :all
    
    response_for :index do |format|
       format.ext { render :layout => false }
       format.ics { render :text => SupportCalendarEvent.to_ics(current_model_without_permission.with_permission(current_user).all) }
       format.html
       format.json do
         render :json => render_json
       end
     end
     
     before :new do
       current_object.support_custom_field_groups.each do |group|
         current_object.support_custom_field_links.build :customfieldgroupid => group.id
         group.support_custom_fields.each do |field|
           current_object.support_custom_field_values.build :customfieldid => field.id
         end
       end
     end
  end
  
  protected
  
  def options_for_json
    {
      :filters => [],
      :methods => ['activity_type'],
      :include => {
        :support_staff_owner => {:only => :fullname},
        :support_calendar_status => {:only => :title}, 
        :support_calendar_label => {:only => :title}, 
        :support_calendar_category => {:only => :title}
      },
      :only => ['subject', 'calendareventid', 'dateline', 'lastupdate', 'startdateline', 'enddateline'],
      :extra => ['support_staff_owner.fullname', 'support_calendar_status.title', 'support_calendar_label.title', 'support_calendar_category.title'],
      :overrides => [
        ['subject', {:hidden => false, :width => 250}],
        ['support_staff_owner.fullname', {:header => 'Owner', :hidden => false, :width => 100}],
        ['activity_type', {:header => 'Type', :hidden => false, :width => 50, :sortable => false}],
      	['support_calendar_status.title', {:header => 'Status', :hidden => false, :width => 50}],
      	['support_calendar_label.title', {:header => 'Label', :hidden => false, :width => 50}],
      	['support_calendar_category.title', {:header => 'Category', :hidden => false, :width => 50}],
      	['dateline', {:header => 'Created At', :renderer => "Ext.util.Format.dateRenderer('m/d/Y g:i A T')", :width => 80}],
      	['lastupdate', {:header => 'Updated At', :renderer => "Ext.util.Format.dateRenderer('m/d/Y g:i A T')", :width => 80}],
      	['startdateline', {:header => 'Start', :hidden => false, :renderer => "Ext.util.Format.dateRenderer('m/d/Y g:i A T')"}],
      	['enddateline', {:header => 'End', :hidden => false, :renderer => "Ext.util.Format.dateRenderer('m/d/Y g:i A T')"}]
      ]
    }
  end
  
  def build_object_with_permission
    build_object_without_permission.with_permission(current_user)
  end
  
  alias_method_chain :build_object, :permission
  
  def current_model_with_permission
    current_model_without_permission.with_permission(current_user).planned
  end
  
  alias_method_chain :current_model, :permission
  
  def current_object_with_permission
    current_object_without_permission.with_permission(current_user)
  end
  
  alias_method_chain :current_object, :permission
    
  def current_objects
    @current_objects ||= paginate_current_objects :include => {
      :support_calendar_status => [:title], :support_calendar_label => [:title], :support_calendar_category => [:title], :support_staff_owner => [:fullname]
    }, :sort => 'support_calendar_event[startdateline]', :dir => 'ASC'
  end
end
