class PatientsController < ApplicationController
  before_filter :signed_in_user

  def show
      @patient = Patient.find(params[:id]) 
      @visits = Patient.find(params[:id]).visits
  end


  def new
      @patient = Patient.new
  end

  def create
      @patient = Patient.new(params[:patient])
    if @patient.save
      flash[:success] = "You have successfuly Created a patient"
      redirect_to @patient
    else
      render 'new'
    end
  end

    def index
        @patients = Patient.all
    end
        
    end

    def edit
    # @patient = patient.find(params[:id])
    end

    def update
    # if @patient.update_attributes(params[:patient])
    #   flash[:success] = "Profile updated"
    #   redirect_to @patient
    # else
    #   render 'edit'
    # end
    end

    private 

    def signed_in_user
      redirect_to signin_url, notice: "Please sign in." unless signed_in?
    end
  