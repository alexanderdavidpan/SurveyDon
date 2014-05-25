class Response < ActiveRecord::Base
  belongs_to :choice
  belongs_to :surveyed_users
  
end
