module PatientsHelper

def sex(type)
    if(type == 1)
         "Male"
    else
        "Female"
  end
end

def find_FirstName(id)
    User.find_by_sql("SELECT 'firstName' FROM 'appusers' WHERE 'userName' ='#{id}'").first.try(:firstName)
       
    end

def find_LastName(id)
    User.find_by_sql("SELECT 'lastName' FROM 'appusers' WHERE 'userName' = '#{id}'").first.try(:lastName)
        
end

# def find_FirstName(id)
#     User.find_by_sql("SELECT 'firstName' FROM appusers WHERE 'userName' ='#{id}'").first.try(:firstName)
       
#     end

# def find_LastName(id)
#     User.find_by_sql("SELECT 'lastName' FROM appusers WHERE 'userName' = '#{id}'").first.try(:lastName)
        
# end

end