class SessionsController < ApplicationController

    def new
        if signed_in?
            redirect_to home_path\
        end
    end
    
    def create
        user = User.find_by_userName(params[:session][:userName].downcase)
            if user && user.status != 0 && user.authenticate(params[:session][:password])
               sign_in user
               redirect_to home_path
            else
				flash.now[:error] = 'Invalid email/password combination'
				render 'new'
      end
    end

    def destroy
        sign_out
        redirect_to root_url
    end


end
