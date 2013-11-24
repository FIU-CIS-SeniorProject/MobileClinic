class Auth < ActiveRecord::Base


attr_accessible :expiration, :user_id, :user_token, :access_token

self.primary_key = "access_token"


end
