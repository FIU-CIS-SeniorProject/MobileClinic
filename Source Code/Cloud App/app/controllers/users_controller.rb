class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:edit, :update, :destroy, :create]
  before_filter :correct_user,   only: [:new, :create]

  def index
      @users = User.all
    end

  def show
    @user = User.find(params[:id])  
  end

  def new
    @user = User.new
  end

  def create
      @user = User.new(params[:user])
    if @user.save
      flash[:success] = "You have successfuly Created a user"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
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
      redirect_to(root_path) unless admin_user?
    end


    def admin_user
      redirect_to(root_path) unless current_user.userType == 0
    end
end
