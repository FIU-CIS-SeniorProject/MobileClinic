class Auth < ActiveRecord::Base


attr_accessible :expiration, :user_id, :user_token, :access_token

set_primary_key :access_token


end
