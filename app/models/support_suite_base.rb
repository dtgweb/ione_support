class SupportSuiteBase < ActiveRecord::Base
  self.abstract_class = true
  
  if RAILS_ENV == "production"
    establish_connection("support")
  else
    establish_connection("support_#{RAILS_ENV}")
  end
  
  before_save :update_timestamp
  
  protected
  
    def to_timestamp(unixtimestamp)
      if unixtimestamp == 0
        nil
      else
        Time.at(unixtimestamp).to_datetime
      end
    end
    
    def from_timestamp(timestamp)
      timestamp.to_time.to_i
    end
    
    def update_timestamp
      # override in subclasses
    end
end
