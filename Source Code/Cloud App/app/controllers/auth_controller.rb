class AuthController < ApplicationController

def access_token
	begin
		postParams = JSON.parse(params[:params])
              
		if(!postParams.has_key?('api_key'))
			@response = {
				:result => 'false' ,
				:data => 'missing api key. Params[api_key]'
			}

			render json:@response
		end

		if(postParams['api_key'])
		  if(!Serial.where("serialnum = ? AND status = ?",postParams['api_key'],1) rescue nil)
          @response = {
            :result => 'false' ,
            :data => 'invalid serial number. Params[api_key]'
          }
  
        render json:@response
      else      
        
			@auth = Auth.create!(
            	:expiration => "", 
           	 	:user_id => "", 
            	:user_token=> "",
            	:charityid => Serial.select("charityid").where("serialnum = ?",postParams['api_key'])[0].charityid,
            	:access_token => generate_access_token()
            )
            
            @response = {
            	:result => 'true',
            	:data => {
            		:access_token => @auth['access_token']
            	}
          	}

          render json:@response
      end
    else
        	@response = {
        		:result => 'false',
        		:data => 'Empty serial number Params[api_key]'
        	}

        	render json:@response
    end

	rescue => error
		@response = {
            :result => 'false',
            :data => "Serial Number not found"
          }

          render json:@response
	end
end

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


