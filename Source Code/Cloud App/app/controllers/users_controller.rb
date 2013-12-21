class UsersController < ApplicationController
  before_filter :signed_in_user
  
  def index
    if current_user.userType != 0
      @users = User.where("\"userType\" = 1 and charityid = ?",current_user.charityid)
    else
      @users = User.all
    end
  end

  def show
    if current_user.userType != 0
      @user = User.where("\"userType\" = '1' and charityid = ?",current_user.charityid).find(params[:id])
      @charity = Charity.where("charityid = ?",current_user.charityid).find(@user.charityid)
    else
      @user = User.find(params[:id])
      @charity = Charity.find(@user.charityid)
    end
  rescue ActiveRecord::RecordNotFound
    flash[:success] = "You are not allow to see this user."
    redirect_to home_path
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "You have successfully Created a user"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    if current_user.userType != 0
      @user = User.where("\"userType\" = ? and charityid = ?",current_user.userType,current_user.charityid).find(params[:id])
    else
      @user = User.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    flash[:success] = "You are not allow to edit this user."
    redirect_to home_path
  end
  
  def change_password
    if current_user.userType != 0
      @user = User.where("\"userType\" = ? and charityid = ?",current_user.userType,current_user.charityid).find(params[:id])
    else
      @user = User.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    flash[:success] = "You are not allow to edit this user."
    redirect_to home_path
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "Profile updated"
      if current_user?(@user)
        sign_in @user
      end
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_index
  end

  private

  def signed_in_user
    redirect_to signin_url, notice: "Please sign in." unless signed_in?
  end

  def correct_user
    redirect_to(home_path) unless admin_user?
  end

  def admin_user
    current_user.userType == 0
  end
end
