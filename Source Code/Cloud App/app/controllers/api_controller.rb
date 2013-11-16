class ApiController < ApplicationController

  def isAuthenticated(token)
    if(Auth.find(token) rescue nil)
      return
    else
      raise 'not authenticated'
    end
  end

  def users
    begin
      postParams = JSON.parse(params[:params]);

      if(!postParams.has_key?('access_token'))
        @response = {
          :result => 'false',
          :data => 'missing access_token'
        }
        render json:@response
        return
      end
      isAuthenticated(postParams['access_token']) 

      @user = Appuser.all
      @response = {
        :result => 'true',
        :data => @user
      }
      render json: @response
    rescue => error
      @response = {
        :result => 'false',
        :data => error.message
      }
      render json: @response
    end
  end

  def user_for_id
    #try to find user for that id
    begin

      #extract post params
      postParams = JSON.parse(params[:params]);

      if(!postParams.has_key?('access_token'))
        @response = {
          :result => 'false',
          :data => 'missing access_token'
        }
        render json:@response
        return
      end
      isAuthenticated(postParams['access_token']) 

      #check - POST has the user id
      if(postParams.has_key?('userName'))
        @user = Appuser.find(postParams['userName'])

        #generate valid response
        @response = {
          :result => 'true',
          :data => @user
        }

        render json:@response
      else
        #generate invalid response - the id has not been set
        @response = {
          :result => 'false',
          :message => 'missing user id. Param ["userId"]'
        }

        render json:@response
      end

      #catch error - no user found for post id
    rescue => error

        #generate response - search for user failed
        @response = {
          :result => 'false',
          :message => error.message
        }
        render json:@response
      end
    end

    def update_user
    #try to find user for that id
    begin

      #extract post params
      postParams = JSON.parse(params[:params]);

      if(!postParams.has_key?('access_token'))
        @response = {
          :result => 'false',
          :data => 'missing access_token'
        }
        render json:@response
        return
      end
      isAuthenticated(postParams['access_token'])

      @users = postParams['Users']
      @users.each do |user|
        #check to see that POST has all the appropriate parameters to
        #create a user. If post does not, return json response with a 
        #result of false

        if(!user.has_key?('userName'))
          @response = {
            :result => 'false',
            :message => 'missing user\'s username - Param ["userName"]'
          }
          render json:@response
          return
        elsif(!user.has_key?('password'))
          @response = {
            :result => 'false',
            :message => 'missing user\'s password - Param ["password"]'
          }
          render json:@response
          return
        elsif(!user.has_key?('firstName'))
          @response = {
            :result => 'false',
            :message => 'missing user\'s first name - Param ["firstName"]'
          }
          render json:@response
          return
        elsif(!user.has_key?('lastName'))
          @response = {
            :result => 'false',
            :message => 'missing user\'s last name - Param ["lastName"]'
          }
          render json:@response
          return
        elsif(!user.has_key?('email'))
          @response = {
            :result => 'false',
            :message => 'missing user\'s email - Param ["email"]'
          }
          render json:@response
          return
        elsif(!user.has_key?('userType'))
          @response = {
            :result => 'false',
            :message => 'missing user\'s userType - Param ["userType"]'
          }
          render json:@response
          return
        elsif(!user.has_key?('status'))
          @response = {
           :result => 'false',
           :message => 'missing user\'s status - Param ["status"]'
         }
         render json:@response
         return
       end

       if(Appuser.find(user['userName']) rescue nil)
        @currentUser = Appuser.find(user['userName'])
        @currentUser.update_attributes :userName => user['userName'], :firstName => user['firstName'], :lastName => user['lastName'], :password => user['password'], :email => user['email'], :userType => user['userType'], :status => user['status']
        @currentUser.save   
        @currentUser.reload
      else
        Appuser.create!(
          userName: user['userName'],
          firstName: user['firstName'],
          lastName: user['lastName'],
          password: user['password'],
          email: user['email'], 
          userType: user['userType'], 
          status: user['status'])
      end
    end

    @response = {
      :result => 'true'
    }

    render json:@response

      #catch error - db error in creating new row
    rescue => error

        #generate response - user could not be created
        @response = {
          :result => 'false',
          :message => error.message
        }
        render json:@response
        return
      end
    end

  def deactivate_user  
    begin
     #extract post params
     postParams = JSON.parse(params[:params]);

     if(!postParams.has_key?('access_token'))
      @response = {
        :result => 'false',
        :data => 'missing access_token'
      }
      render json:@response
      return
    end
    isAuthenticated(postParams['access_token'])

    if(!postParams.has_key?('userName'))
      @response = {
        :result => 'false',
        :message => 'missing user\'s username - Param ["userName"]'
      }
      render json:@response
      return
    end
    @user = Appuser.find(postParams['userName'])
    @user.update_attribute(:status, 0)
    @user.save
    @user.reload

    #generate valid response
    @response = {
      :result => 'true',
      :data => Appuser.find(postParams['userName'])
    }

    render json:@response

    #catch error - db error in creating new row
    rescue => error

      #generate response - user could not be created
      @response = {
        :result => 'false',
        :message => error.message
      }
      render json:@response
    end
  end

  def patients
    begin
      postParams = JSON.parse(params[:params]);

      if(!postParams.has_key?('access_token'))
        @response = {
          :result => 'false',
          :data => 'missing access_token'
        }
        render json:@response
        return
      end
      isAuthenticated(postParams['access_token'])

      @patients = Patient.all
      @response = {
        :result => 'true',
        :data => @patients
      }
      render json:@response

    rescue => error

      @response = {
        :result => 'false',
        :data => error.message
      }

      render json: @response

    end
  end

  def patient_for_id
    #try to find patient for that id
    begin
      #extract post params
      postParams = JSON.parse(params[:params]);

      if(!postParams.has_key?('access_token'))
        @response = {
          :result => 'false',
          :data => 'missing access_token'
        }
        render json:@response
        return
      end
      isAuthenticated(postParams['access_token'])

      #check - POST has the patient id
      if(!postParams.has_key?('patientId'))
        @response = {
          :result => 'false',
          :message => 'missing user id. Param ["patientId"]'
        }
        render json:@response
        return
      else
        @patient = Patient.find(postParams['patientId'])
        #generate valid response
        @response = {
          :result => 'true',
          :data => @patient
        }

        render json:@response
      end
      #catch error - no user found for post id
    rescue => error

        #generate response - user could not be created
        @response = {
          :result => 'false',
          :message => error.message
        }
        render json:@response
      end
  end

  def update_patient
    #try to find user for that id
    begin

    #extract post params
    postParams = JSON.parse(params[:params]);
    if(!postParams.has_key?('access_token'))
      @response = {
        :result => 'false',
        :data => 'missing access_token'
      }
      render json:@response
      return
    end
    isAuthenticated(postParams['access_token'])

    @patients = postParams['Patients']
    @patients.each do |patient|

    #check to see that POST has the user id
    if(!patient.has_key?('patientId'))
      @response = {
        :result => 'false',
        :message => 'missing patient\'s created at time - Param ["patientId"]'
      }
      render json:@response
      return
    elsif(!patient.has_key?('firstName'))
      @response = {
        :result => 'false',
        :message => 'missing patient\'s first name - Param ["firstName"]'
      }
      render json:@response
      return
    elsif(!patient.has_key?('familyName'))
      @response = {
        :result => 'false',
        :message => 'missing patient\'s family name - Param ["familyName"]'
      }
      render json:@response
      return
    elsif(!patient.has_key?('villageName'))
      @response = {
        :result => 'false',
        :message => 'missing patient\'s village name - Param ["villageName"]'
      }
      render json:@response
      return
    elsif(!patient.has_key?('age'))
      @response = {
        :result => 'false',
        :message => 'missing patient\'s date of birth - Param ["age"]'
      }
      render json:@response
      return
    elsif(!patient.has_key?('sex'))
      @response = {
        :result => 'false',
        :message => 'missing patient\'s sex - Param ["sex"]'
      }
      render json:@response
      return
    elsif(!patient.has_key?('patientId'))
      @response = {
        :result => 'false',
        :message => 'missing patient\'s patientId - Param ["patientId"]'
      }
      render json:@response
      return
    elsif(!params.has_key?('picture'))
      patient['picture'] = nil
    end

    if(Patient.find(patient['patientId']) rescue nil)
      @currentPatient = Patient.find(patient['patientId'])
      @currentPatient.update_attributes :firstName => patient['firstName'], :familyName => patient['familyName'], :villageName => patient['villageName'], :age => patient['age'], :sex => patient['sex'],  :picture => patient['picture'], :patientId => patient['patientId']
      @currentPatient.save   
      @currentPatient.reload
    else

      Patient.create!(
        :patientId => patient['patientId'], 
        :firstName => patient['firstName'], 
        :familyName=> patient['familyName'],
        :villageName => patient['villageName'], 
          :age=> patient['age'], #password_confirmation: "foobar",
          :sex => patient['sex'], 
          :picture => patient['picture']
          )
    end
  end

  @response = {
    :result => 'true'
  }

  render json:@response

    #catch error - db error in creating new row
  rescue => error

      #generate response - user could not be created
      @response = {
        :result => 'false',
        :message => error.message
      }
      render json:@response
    end
  end

  def upload_patient_image
    # respond_to do |format|
    # format.json {
    begin

    # render json:params
    # return

    if(Patient.find(params[:patientId]) rescue nil)

      directory = "#{Rails.root}/public/image/"
      if(!File.directory? directory)
        Dir::mkdir("#{Rails.root}/public/image/")
      end



      file = File.new("#{Rails.root}/public/image/puta.png")

      File.open("#{Rails.root}/public/image/puta.png", 'wb') do |file|  
        file.write(params[:file].read)  
      end  

      file.close  

      @currentPatient = Patient.find(params[:patientId])


      @response = {
        :result => 'false'
      }

      render json:@response
      return
    end
  rescue => error

      #generate response - user could not be created
      @response = {
        :result => 'false',
        :message => error.message
      }
      render json:@response
    end

    # #convert it from hex to binary
    #       pixels = hex_to_string(pixels)
    # #create it as a file
    #         data = StringIO.new(pixels)
    # #set file types
    #         data.class.class_eval { attr_accessor :original_filename, :content_type }
    #         data.original_filename = "test1.jpeg"
    #         data.content_type = "image/jpeg"
    # #set the image id, had some weird behavior when i didn't
    #         # @image.id = Image.count + 1
    # #upload the data to Amazon S3
    #         upload(data)
    # #save the image
    #         # if @image.save!
    #         #   render :nothing => true
    #         # end
    #   }
    # end
  end

  def visits

    begin

      postParams = JSON.parse(params[:params]);

      if(!postParams.has_key?('access_token'))
        @response = {
          :result => 'false',
          :data => 'missing access_token'
        }
        render json:@response
        return
      end
      isAuthenticated(postParams['access_token'])

      @visits = Visit.all
      @response = {
        :result => 'true',
        :data => @visits
      }

      render json: @response

    rescue => error
      @response = {
        :result => 'false',
        :data => error.message
      }
      render json:@response

    end
  end

  def visits_for_id
      #try to find patient for that id
      begin

      #extract post params
      postParams = JSON.parse(params[:params]);

      if(!postParams.has_key?('access_token'))
        @response = {
          :result => 'false',
          :data => 'missing access_token'
        }
        render json:@response
        return
      end
      isAuthenticated(postParams['access_token'])

      #check - POST has the patient id
      if(!postParams.has_key?('triageIn'))
        @response = {
          :result => 'false',
          :message => 'missing primary key. Param ["triageIn"]'
        }
        render json:@response
        return
      else
        @patient = Visit.find(postParams['triageIn'])
        #generate valid response
        @response = {
          :result => 'true',
          :data => @patient
        }

        render json:@response
      end
      #catch error - db error in creating new row
      rescue => error

        #generate response - user could not be created
        @response = {
          :result => 'false',
          :message => error.message
        }
        render json:@response
      end
  end

  def visits_for_patient
      #try to find patient for that id
      begin

      #extract post params
      postParams = JSON.parse(params[:params]);

      if(!postParams.has_key?('access_token'))
        @response = {
          :result => 'false',
          :data => 'missing access_token'
        }
        render json:@response
        return
      end
      isAuthenticated(postParams['access_token'])

      #check - POST has the patient id
      if(!postParams.has_key?('patientId'))
        @response = {
          :result => 'false',
          :message => 'missing patient id. Param ["patientId"]'
        }
        render json:@response
        return
      else
        @patient = Visit.find(postParams['patientId'])
        #generate valid response
        @response = {
          :result => 'true',
          :data => @patient
        }

        render json:@response
      end
      #catch error - db error in creating new row
      rescue => error

        #generate response - user could not be created
        @response = {
          :result => 'false',
          :message => error.message
        }
        render json:@response
      end
  end

  def update_visit
      #try to find user for that id
      begin

      #extract post params
      postParams = JSON.parse(params[:params]);

      if(!postParams.has_key?('access_token'))
        @response = {
          :result => 'false',
          :data => 'missing access_token'
        }
        render json:@response
        return
      end
      isAuthenticated(postParams['access_token'])

      @visits = postParams['Visitation']
      @visits.each do |visit|
      #check to see that POST has the user id
      if(!visit.has_key?('triageIn'))
        @response = {
          :result => 'false',
          :message => 'missing time patient first saw nurse - Param ["triageIn"]'
        }
        render json:@response
        return
      elsif(!visit.has_key?('weight'))
        @response = {
          :result => 'false',
          :message => 'missing patient\'s weight - Param ["weight"]'
        }
        render json:@response
        return
      elsif(!visit.has_key?('conditions'))
        @response = {
          :result => 'false',
          :message => 'missing patient\'s condition - Param ["conditions"]'
        }
        render json:@response
        return
      elsif(!visit.has_key?('bloodPressure'))
        @response = {
          :result => 'false',
          :message => 'missing patient\'s blood pressure  - Param ["bloodPressure"]'
        }
        render json:@response
        return
      elsif(!visit.has_key?('triageOut'))
        @response = {
          :result => 'false',
          :message => 'missing time patient left triage- Param ["triageOut"]'
        }
        render json:@response
        return
      elsif(!visit.has_key?('doctorIn'))
        @response = {
          :result => 'false',
          :message => 'missing time patient saw doctor - Param ["doctorIn"]'
        }
        render json:@response
        return
      elsif(!visit.has_key?('doctorOut'))
        @response = {
          :result => 'false',
          :message => 'missing time patient left doctor- Param ["doctorOut"]'
        }
        render json:@response
        return
      elsif(!visit.has_key?('doctorId'))
        @response = {
          :result => 'false',
          :message => 'missing patient\'s doctor id - Param ["doctorId"]'
        }
        render json:@response
        return
      elsif(!visit.has_key?('nurseId'))
        @response = {
          :result => 'false',
          :message => 'missing patient\'s nurse id - Param ["nurseId"]'
        }
        render json:@response
        return
      elsif(!visit.has_key?('patientId'))
        @response = {
          :result => 'false',
          :message => 'missing patient\'s id - Param ["patientId"]'
        }
        render json:@response
        return
      elsif(!visit.has_key?('observation'))
        @response = {
          :result => 'false',
          :message => 'missing patient\'s id - Param ["observation"]'
        }
        render json:@response
        return

      end
      if(Visit.find(visit['triageIn']) rescue nil)
        @currentVisit = Visit.find(visit['triageIn'])
        @currentVisit.update_attributes :weight => visit['weight'], :conditions => visit['conditions'], :bloodPressure => visit['bloodPressure'], :triageIn => visit['triageIn'], :doctorIn => visit['doctorIn'], :doctorOut => visit['doctorOut'], :nurseId => visit['nurseId'], :patientId => visit['patientId'], :observation => visit['observation']
        @currentVisit.save
        @currentVisit.reload
      else
        Visit.create!(
          :triageIn => visit['triageIn'],
          :weight => visit['weight'],
          :conditions => visit['conditions'],
          :bloodPressure => visit['bloodPressure'],
          :triageIn => visit['triageIn'],
          :doctorIn => visit['doctorIn'],
          :doctorOut => visit['doctorOut'], 
          :doctorId => visit['doctorId'],
          :nurseId => visit['nurseId'],
          :patientId => visit['patientId'],
          :observation => visit['observation'])
      end        
      end
      @response = {
        :result => 'true'
      }

      render json:@response
      #catch error - db error in creating new row
      rescue => error

        #generate response - user could not be created
        @response = {
          :result => 'false',
          :message => error.message
        }
        render json:@response
      end
  end

  def prescriptions
  begin
    postParams = JSON.parse(params[:params]);

    if(!postParams.has_key?('access_token'))
      @response = {
        :result => 'false',
        :data => 'missing access_token'
      }
      render json:@response
      return
    end
    isAuthenticated(postParams['access_token'])

    @prescriptions = Prescription.all
    @response = {
      :result => 'true',
      :data => @prescriptions
    }

    render json: @response

  rescue
    @response = {
      :result => 'false',
      :message => error.message
    }
    render json:@response
  end
  end

  def prescriptions_for_id
    begin

    #extract post params
    postParams = JSON.parse(params[:params]);

    if(!postParams.has_key?('access_token'))
      @response = {
        :result => 'false',
        :data => 'missing access_token'
      }
      render json:@response
      return
    end
    isAuthenticated(postParams['access_token'])

    #check - POST has the patient id
    if(!postParams.has_key?('prescribedAt'))
      @response = {
        :result => 'false',
        :message => 'missing primary key. Param ["prescribedAt"]'
      }
      render json:@response
      return
    else
      @prescription = Prescription.find(postParams['prescribedAt'])
      #generate valid response
      @response = {
        :result => 'true',
        :data => @prescription
      }

      render json:@response
    end
    #catch error - db error in creating new row
    rescue => error

      #generate response - user could not be created
      @response = {
        :result => 'false',
        :message => error.message
      }
      render json:@response
    end
  end

  def prescriptions_for_visit
      begin

      #extract post params
      postParams = JSON.parse(params[:params]);

      if(!postParams.has_key?('access_token'))
        @response = {
          :result => 'false',
          :data => 'missing access_token'
        }
        render json:@response
        return
      end
      isAuthenticated(postParams['access_token'])

      #check - POST has the patient id
      if(!postParams.has_key?('visitId'))
        @response = {
          :result => 'false',
          :message => 'missing primary key. Param ["visitId"]'
        }
        render json:@response
        return
      else
        @prescription = Prescription.find(postParams['visitId'])
        #generate valid response
        @response = {
          :result => 'true',
          :data => @prescription
        }

        render json:@response
      end
      #catch error - db error in creating new row
      rescue => error

        #generate response - user could not be created
        @response = {
          :result => 'false',
          :message => error.message
        }
        render json:@response
      end
  end

  def update_prescription
      #try to find user for that id
      begin

      #extract post params
      postParams = JSON.parse(params[:params]);

      if(!postParams.has_key?('access_token'))
        @response = {
          :result => 'false',
          :data => 'missing access_token'
        }
        render json:@response
        return
      end
      isAuthenticated(postParams['access_token'])

      @prescriptions = postParams['Prescription']
      @prescriptions.each do |prescription|
      #check to see that POST has all the appropriate parameters to
      #create a user. If post does not, return json response with a 
      #result of false
      if(!prescription.has_key?('prescribedAt'))
        @response = {
          :result => 'false',
          :message => 'missing user\'s userId - Param ["prescribedAt"]'
        }
        render json:@response
        return
      elsif(!prescription.has_key?('medId'))
        @response = {
          :result => 'false',
          :message => 'missing user\'s username - Param ["medId"]'
        }
        render json:@response
        return
      elsif(!prescription.has_key?('tabletsPerDay'))
        @response = {
          :result => 'false',
          :message => 'missing user\'s password - Param ["tabletsPerDay"]'
        }
        render json:@response
        return
      elsif(!prescription.has_key?('timeOfDay'))
        @response = {
          :result => 'false',
          :message => 'missing user\'s first name - Param ["timeOfDay"]'
        }
        render json:@response
        return
      elsif(!prescription.has_key?('instruction'))
        @response = {
          :result => 'false',
          :message => 'missing user\'s last name - Param ["instruction"]'
        }
        render json:@response
        return
      elsif(!prescription.has_key?('visitId'))
        @response = {
          :result => 'false',
          :message => 'missing user\'s email - Param ["visitId"]'
        }
        render json:@response
        return
      end

      if (Prescription.find(prescription['prescribedAt']) rescue nil)
        @currentPrescription = Prescription.find(prescription['prescribedAt'])
        @currentPrescription.update_attributes :prescribedAt => prescription['prescribedAt'], :medId => prescription['medId'], :tabletsPerDay => prescription['tabletsPerDay'], :timeOfDay => prescription['timeOfDay'], :instruction => prescription['instruction'], :visitId => prescription['visitId']
        @currentPrescription.save
        @currentPrescription.reload
      else

        Prescription.create!(
          :prescribedAt => prescription['prescribedAt'], 
          :medId => prescription['medId'], 
          :tabletsPerDay => prescription['tabletsPerDay'],
          :timeOfDay => prescription['timeOfDay'], 
          :instruction => prescription['instruction'],
          :visitId => prescription['visitId']) 
      end
      end
      @response = {
        :result => 'true'          
      }

      render json:@response
      #catch error - db error in creating new row
      rescue => error

        #generate response - user could not be created
        @response = {
          :result => 'false',
          :message => error.message
        }
        render json:@response
      end
  end

  def medications
    begin
      postParams = JSON.parse(params[:params]);

      if(!postParams.has_key?('access_token'))
        @response = {
          :result => 'false',
          :data => 'missing access_token'
        }
        render json:@response
        return
      end
      isAuthenticated(postParams['access_token'])

      @medications = Medication.all
      @response = {
        :result => 'true',
        :data => @medications
      }

      render json: @response

    rescue => error
      @response = {
        :result => 'false',
        :message => error.message
      }

      render json: @response
    end
  end

  def medications_for_id
    begin

    #extract post params
    postParams = JSON.parse(params[:params]);

    if(!postParams.has_key?('access_token'))
      @response = {
        :result => 'false',
        :data => 'missing access_token'
      }
      render json:@response
      return
    end
    isAuthenticated(postParams['access_token'])

    #check - POST has the patient id
    if(!postParams.has_key?('medId'))
      @response = {
        :result => 'false',
        :message => 'missing primary key. Param ["medId"]'
      }
      render json:@response
      return
    else
      @medication = Medication.find(postParams['medId'])
      #generate valid response
      @response = {
        :result => 'true',
        :data => @medication
      }

      render json:@response
    end
    #catch error - db error in creating new row
    rescue => error

      #generate response - user could not be created
      @response = {
        :result => 'false',
        :message => error.message
      }
      render json:@response
    end
  end

  def update_medication

    #extract post params
    postParams = JSON.parse(params[:params]);

    if(!postParams.has_key?('access_token'))
      @response = {
        :result => 'false',
        :data => 'missing access_token'
      }
      render json:@response
      return
    end
    isAuthenticated(postParams['access_token'])

    @medications = postParams['Medication']
    @medications.each do |medication|
    #check to see that POST has the user id
    if(!medication.has_key?('medId'))
      @response = {
        :result => 'false',
        :message => 'missing time patient first saw nurse - Param ["triageIn"]'
      }
      render json:@response
      return
    elsif(!medication.has_key?('name'))
      @response = {
        :result => 'false',
        :message => 'missing patient\'s weight - Param ["weight"]'
      }
      render json:@response
      return
    elsif(!medication.has_key?('numContainers'))
      @response = {
        :result => 'false',
        :message => 'missing patient\'s condition - Param ["conditions"]'
      }
      render json:@response
      return
    elsif(!medication.has_key?('tabletsPerContainer'))
      @response = {
        :result => 'false',
        :message => 'missing patient\'s blood pressure  - Param ["bloodPressure"]'
      }
      render json:@response
      return
    elsif(!medication.has_key?('expiration'))
      @response = {
        :result => 'false',
        :message => 'missing time patient left triage- Param ["triageOut"]'
      }
      render json:@response
      return
    elsif(!medication.has_key?('doseOfTablets'))
      @response = {
        :result => 'false',
        :message => 'missing time patient saw doctor - Param ["doctorIn"]'
      }
      render json:@response
      return

    end

    if(Medication.find(medication['medId']) rescue nil)
     @currentMedication = Medication.find(medication['medId'])
     @currentMedication.update_attributes :name => medication['name'], :numContainers => medication['numContainers'], :tabletsPerContainer => medication['tabletsPerContainer'], :expiration => medication['expiration'], :doseOfTablets => medication['doseOfTablets']
     @currentMedication.save
     @currentMedication.reload   
    else
      Medication.create!(
        :medId => medication['medId'],
        :name => medication['name'],
        :numContainers => medication['numContainers'],
        :tabletsPerContainer => medication['tabletsPerContainer'],
        :expiration => medication['expiration'],
        :doseOfTablets => medication['doseOfTablets'])
    end
    end          
    @response = {
      :result => 'true',
    }

    render json:@response

    #catch error - db error in creating new row
    rescue => error

      #generate response - user could not be created
      @response = {
        :result => 'false',
        :message => error.message
      }
      render json:@response
    end
  end

  def edit_medication
    begin
    #extract post params
    postParams = JSON.parse(params[:params]);

    if(!postParams.has_key?('access_token'))
      @response = {
        :result => 'false',
        :data => 'missing access_token'
      }
      render json:@response
      return
    end
    isAuthenticated(postParams['access_token'])
    #check to see that POST has the user id
    if(!postParams.has_key?('medId'))
      @response = {
        :result => 'false',
        :message => 'missing time patient first saw nurse - Param ["triageIn"]'
      }
      render json:@response
      return
    elsif(!postParams.has_key?('name'))
      @response = {
        :result => 'false',
        :message => 'missing patient\'s weight - Param ["weight"]'
      }
      render json:@response
      return
    elsif(!postParams.has_key?('numContainers'))
      @response = {
        :result => 'false',
        :message => 'missing patient\'s condition - Param ["conditions"]'
      }
      render json:@response
      return
    elsif(!postParams.has_key?('tabletsPerContainer'))
      @response = {
        :result => 'false',
        :message => 'missing patient\'s blood pressure  - Param ["bloodPressure"]'
      }
      render json:@response
      return
    elsif(!postParams.has_key?('expiration'))
      @response = {
        :result => 'false',
        :message => 'missing time patient left triage- Param ["triageOut"]'
      }
      render json:@response
      return
    elsif(!postParams.has_key?('doseOfTablets'))
      @response = {
        :result => 'false',
        :message => 'missing time patient saw doctor - Param ["doctorIn"]'
      }
      render json:@response
      return

    end
    @medication = Medication.find(postParams['medId'])
    @medication.update_attributes :name => postParams['name'], :numContainers => postParams['numContainers'], :tabletsPerContainer => postParams['tabletsPerContainer'], :expiration => postParams['expiration'], :doseOfTablets => postParams['doseOfTablets']
    @medication.save
    @medication.reload            
    @response = {
      :result => 'true',
      :data => Medication.find(postParams['medId'])
    }

    render json:@response

    #catch error - db error in creating new row
    rescue => error

      #generate response - user could not be created
      @response = {
        :result => 'false',
        :message => error.message
      }
      render json:@response
    end
  end