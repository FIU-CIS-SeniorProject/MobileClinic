module UsersHelper
  def type_of_user(type)
    if(type == 0)
      "Admin"
    elsif(type == 1)
      "Charity Local Admin"
    end
  end

  def status(type)
    if(type == 1)
      "Active"
    else
      "Inactive"
    end
  end
end