class SerialsController < ApplicationController
  before_filter :signed_in_user
  
  def index
   if current_user.userType != 0
      @serials = Serial.where("charityid = ?",current_user.charityid)
    else
      @serials = Serial.all
    end
  end

  def show
    if current_user.userType != 0
      @serial = Serial.where("charityid = ?",current_user.charityid).find(params[:id])
    else
      @serial = Serial.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    flash[:success] = "You are not allow to see this serial number."
    redirect_to home_path
  end

  def new
    @serial = Serial.new
  end

  def edit
    if current_user.userType != 0
      @serial = Serial.where("charityid = ?",current_user.charityid).find(params[:id])
    else
      @serial = Serial.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    flash[:success] = "You are not allow to edit this serial number."
    redirect_to home_path
  end

  def create
    @serial = Serial.new(params[:serial])
    if @serial.save
      flash[:notice] = "You have successfully Created a serial number"
      redirect_to @serial
    else
      render 'new'
    end
  end

  def update
    @serial = Serial.find(params[:id])
    if @serial.update_attributes(params[:serial])
      flash[:notice] = "Serial updated"
      redirect_to @serial
    else
      render 'edit'
    end
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
