class PasswordResetsController < ApplicationController
  def create
    user = User.find_by_email(params[:email])
    if user
      question = params[:question]
      answer = params[:answer].downcase
      if answer == user.answer && question == user.question 
        redirect_to edit_password_reset_path user
      else
        redirect_to root_url
      end
    else
      redirect_to root_url
    end
  end

  def edit
    @user = User.find_by_userName!(params[:id])
  end
  
  def update  
    @user = User.find_by_userName!(params[:id])
    if @user.update_attributes(params[:user])  
      redirect_to root_url
    else  
      render :edit
    end  
  end
end