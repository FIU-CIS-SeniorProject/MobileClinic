module AppusersHelper

    def type_of_appuser(type)
      if(type == 0)
        "Nurse"
      elsif(type == 1)
        "Doctor"
     elsif(type == 2)
      "Pharmacist"
        elsif(type == 3)
      "App Admin"
    end
  end

    def admin_user?
    current_user.userType == 0
  end

end

