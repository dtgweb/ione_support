require File.dirname(__FILE__) + '/../../../../test/test_helper'

Factory.define :support_ticket_status do |f|
  f.title 'open'
end

Factory.define :support_ticket do |f|
  f.email 'email@email.com'
  f.support_ticket_status Factory(:support_ticket_status)
end