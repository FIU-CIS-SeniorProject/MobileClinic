class StaticPagesController < ApplicationController
before_filter :signed_in_user

  def home
  	@patients = Patient.order(:updated_at)
  	@newVisits = Visit.where("created_at = updated_at")
  	@returnVisits = Visit.where("created_at != updated_at")
  	@visits = Visit.order(:created_at)
  end

  def createuser
  end


    def get_visit_count
    	visits.count    	
    end

  private 

    def signed_in_user
      redirect_to signin_url, notice: "Please sign in." unless signed_in?
    end

end
