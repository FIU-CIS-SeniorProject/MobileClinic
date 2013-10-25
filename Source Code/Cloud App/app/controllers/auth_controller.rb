class AuthController < ApplicationController
@@api_key = "12345"

def access_token
	begin
		postParams = JSON.parse(params[:params])

		if(!postParams.has_key?('api_key'))
			@response = {
				:result => 'false' ,
				:message => 'missing api key. Params[api_key]'
			}

			render json:@response
		end

		if(postParams['api_key'] )

			@auth = Auth.create!(
            	:expiration => "", 
           	 	:user_id => "", 
            	:user_token=> "",
            	:access_token => generate_access_token()
            )

            @response = {
            	:result => 'true',
            	:data => {
            		:access_token => @auth['access_token']
            	}
          	}

          render json:@response
        else
        	@response = {
        		:result => 'false',
        		:message => 'api_key invalid'
        	}

        	render json:@response
        end

	rescue => error
		
		@response = {
            :result => 'false',
            :data => error.message
          }

          render json:@response
	end
end

# def user_token

# begin

# 	postParams = JSON.parse(params[:params])

# 	if(!postParams.has_key?('access_token'))
# 		@response = {
# 				:result => 'false' ,
# 				:message => 'missing access token. Params[api_key]'
# 			}

# 		render json:@response
# 	end

# 	@auth = Auth.find(postParams['access_token'])
#     @auth.update_attribute(:user_token, create_user_token())
#     @auth.update_attribute(:user_id, postParams['access_token'])
#     @auth.update_attribute(:expiration, set_expiration())
#     @auth.save
#     @auth.reload

#     @response = {
# 				:result => 'true' ,
# 				:data => @auth
# 			}

# 		render json:@response
	
# rescue => error
	
# 	@response = {
# 				:result => 'false' ,
# 				:message => error.message
# 			}

# 		render json:@response

# end

def self.find_by_id(id)
    find(id) rescue nil
end

end
private
	def create_user_token
      return SecureRandom.urlsafe_base64
    end

    def generate_access_token
    	begin
    		@access_token = SecureRandom.hex
    	end while Auth.exists?(@access_token)
    	return @access_token
    end

    def set_expiration
    	#meant to expire in one day
    	return DateTime.now.to_i + 86400
    end


