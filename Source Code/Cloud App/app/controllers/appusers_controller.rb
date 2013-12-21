class AppusersController < ApplicationController
  before_filter :signed_in_user
  
  def index
    if current_user.userType != 0
      @appuser = Appuser.where("charityid = ?",current_user.charityid)
    else
      @appuser = Appuser.all
    end
  end

  def show
    if current_user.userType != 0
      @appuser = Appuser.where("charityid = ?",current_user.charityid).find(params[:id])
    else
      @appuser = Appuser.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    flash[:success] = "You are not allow to see this user."
    redirect_to home_path
  end

  def new
    @appuser = Appuser.new
  end

  def create
    @appuser = Appuser.new(params[:appuser])
    if @appuser.save
      flash[:notice] = "You have successfuly created a user"
      redirect_to @appuser
    else
      render 'new'
    end
  end

  def edit
    if current_user.userType != 0
      @appuser = Appuser.where("charityid = ?",current_user.charityid).find(params[:id])
    else
      @appuser = Appuser.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    flash[:success] = "You are not allow to edit this user."
    redirect_to home_path
  end
  
  def change_password
    if current_user.userType != 0
      @appuser = Appuser.where("charityid = ?",current_user.charityid).find(params[:id])
    else
      @appuser = Appuser.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    flash[:success] = "You are not allow to edit this user."
    redirect_to home_path
  end

  def update
    @appuser = Appuser.find(params[:id])
    if @appuser.update_attributes(params[:appuser])
      flash[:notice] = "Profile updated"
      redirect_to @appuser
    else
      render 'edit'
    end
  end

  private

  def signed_in_user
    redirect_to signin_url, notice: "Please sign in." unless signed_in?
  end

  def correct_user
    redirect_to(root_path) unless admin_user?
  end
end
