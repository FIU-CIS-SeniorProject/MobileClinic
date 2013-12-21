class MedicationsController < ApplicationController
  before_filter :signed_in_user
  
  def show
    @medication = Medication.find(params[:id])
  end

  def new
    @medication = Medication.new
  end

  def create
    @medication = Medication.new(params[:medication])
    if @medication.save
      flash[:notice] = "You have successfuly Created a medication"
      redirect_to @medication
    else
      render 'new'
    end
  end

  def index
    @medications = Medication.order(:medName)
    respond_to do |format|
      format.html
      format.csv {send_data @medications.to_csv}
    end
  end
  
  def edit
    @medication = Medication.find(params[:id])
  end
  
  def update
    @medication = Medication.find(params[:id])
    if @medication.update_attributes(params[:medication])
      flash[:notice] = "Medication updated"
      redirect_to @medication
    else
      render "edit"
    end
  end

end

private

def signed_in_user
  redirect_to signin_url, notice: "Please sign in." unless signed_in?
end
