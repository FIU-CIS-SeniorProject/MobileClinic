class PatientsController < ApplicationController
  before_filter :signed_in_user
  
  def index
    @patients = Patient.order(:firstName)
    respond_to do |format|
      format.html
      format.csv {send_data @patients.to_csv}
    end
  end
  
  def show
    @patient = Patient.find(params[:id])
    @visits = Visit.where("\"patientId\" = ?",params[:id]).order("\"triageIn\" DESC")
  end
end

private

def signed_in_user
  redirect_to signin_url, notice: "Please sign in." unless signed_in?
end
