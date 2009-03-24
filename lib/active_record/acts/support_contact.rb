module ActiveRecord
  module Acts
    module SupportContact
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def acts_as_support_contact(options = {})
          has_dependency :support_contact, 
            {:attrs => [:fullname, :companyname, :businessaddress, :businesstelephonenumber, :othertelephonenumber, :hometelephonenumber, :mobiletelephonenumber, 
              :businessfaxnumber, :businesshomepage, :mailingaddress, 
              :email1address, :email2address, :email3address, :lastupdate],
            :foreign_key => :email1address, :primary_key => :email, :validates_presence_if => false, :prefix => "support"}.merge(options)
          
          extend ActiveRecord::Acts::SupportContact::SingletonMethods
          include ActiveRecord::Acts::SupportContact::InstanceMethods
        end
      end
      
      module SingletonMethods

      end
      
      module InstanceMethods

      end
      
    end
  end
end