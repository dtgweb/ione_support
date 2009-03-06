module ActiveRecord
  module Acts
    module SupportSuiteUser
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def acts_as_support_suite_user(mappings = {})
          has_many :support_user_emails, :foreign_key => :email, :primary_key => :contact_email
          
          
          attr_accessor :support_field_mappings
          
          write_attribute :support_field_mappings, mappings
          
          before_validation :update_support_suite_fields
          
          extend ActiveRecord::Acts::Customer::SingletonMethods
          include ActiveRecord::Acts::Customer::InstanceMethods
        end
      end
      
      module SingletonMethods

      end
      
      module InstanceMethods
        def update_support_suite_fields
          support_field_mappings.each_pair do |key,value|
            support_suite_user_email.attributes(key) = self.send(value)
          end
        end
      end
      
    end
  end
end