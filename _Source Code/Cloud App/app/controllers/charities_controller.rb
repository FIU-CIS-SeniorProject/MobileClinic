class CharitiesController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user
  
  # GET /charities
  def index
    @charities = Charity.all
  end

  # GET /charities/1
  def show
    @charity = Charity.find(params[:id])
  end

  # GET /charities/new
  def new
    @charity = Charity.new
  end

  # POST /charities
  def create
    @charity = Charity.new(params[:charity])
    if @charity.save
      flash[:notice] = "You have successfully Created a Charity"
      redirect_to @charity
    else
      render "new"
    end
  end

  # GET /charities/1/edit
  def edit
    @charity = Charity.find(params[:id])
  end

  # PUT /charities/1
  def update
    @charity = Charity.find(params[:id])
    if @charity.update_attributes(params[:charity])
      flash[:notice] = "Charity updated"
      redirect_to @charity
    else
      render "edit"
    end
  end

  private

  def signed_in_user
    redirect_to signin_url, notice: "Please sign in." unless signed_in?
  end

  def correct_user
    redirect_to(root_path) unless admin_user?
  end

  def admin_user
    redirect_to(root_path) unless current_user.userType == 0
  end
end