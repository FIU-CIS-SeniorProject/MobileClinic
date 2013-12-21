class ApiController < ApplicationController

  def isAuthenticated(token)
    if(Auth.find(token) rescue nil)
      return
    else
      raise 'Not authenticated'
    end
  end

  def users
    begin
      postParams = JSON.parse(params[:params]);
      if(!postParams.has_key?('access_token'))
        @response = {
          :result => 'false',
          :data => 'Missing access_token'
        }
        render json:@response
        return
      end
      isAuthenticated(postParams['access_token'])
      @user = Appuser.select("\"userName\",password,\"firstName\",\"lastName\",email,\"userType\",status,charityid").where("status = ? and charityid = ?",1,Integer(Auth.select("charityid").where("access_token = ?",postParams['access_token'])[0].charityid))
      @response = {
        :result => 'true',
        :data => @user
      }
      
    render json: @response
    rescue => error
      @response = {
        :result => 'false',
        :data => 'Not found any users'
      }
      render json: @response
    end
  end

  def patients
    begin
      postParams = JSON.parse(params[:params]);

      if(!postParams.has_key?('access_token'))
        @response = {
          :result => 'false',
          :data => 'Missing access_token'
        }
        render json:@response
        return
      end
      isAuthenticated(postParams['access_token'])      
      if(postParams.has_key?('Timestamp'))
        @timestamp = Time.at(postParams['Timestamp'])
        @lowest = Time.at(-2146949393)
        if (@timestamp < @lowest)
          @timestamp = @lowest                
        end
        @patients = Patient.select("\"patientId\",\"firstName\",\"villageName\",\"familyName\",age,sex").where("updated_at > ?",@timestamp)
      else
        @patients = Patient.select("\"patientId\",\"firstName\",\"villageName\",\"familyName\",age,sex")
      end
      @response = {
        :result => 'true',
        :data => @patients
      }
      render json:@response

    rescue => error
      @response = {
        :result => 'false',
        :data => 'Not found any patient'
      }

      render json: @response

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
        :data => 'Missing access_token'
      }
      render json:@response
      return
    end
    isAuthenticated(postParams['access_token'])
    @patients = postParams['Patients']
    @patients.each do |patient|

      if(!patient.has_key?('firstName'))
        @response = {
          :result => 'false',
          :data => 'Missing patient\'s first name - Param ["firstName"]'
        }
        render json:@response
        return
      elsif(!patient.has_key?('villageName'))
        patient['villageName'] = nil
      elsif(!patient.has_key?('age'))
        patient['age'] = 0
      elsif(!patient.has_key?('familyName'))
        patient['familyName'] = nil
      elsif(!patient.has_key?('label'))
        patient['label'] = nil
      elsif(!patient.has_key?('sex'))
        patient['sex'] = nil
      elsif(!patient.has_key?('patientId'))
        @response = {
          :result => 'false',
          :data => 'Missing patient\'s patientId - Param ["patientId"]'
        }
        render json:@response
        return
      end
      
      if(Patient.find(patient['patientId']) rescue nil)
        @currentPatient = Patient.find_by_patientId(patient['patientId'])
        @currentPatient.update_attributes(
          :firstName => patient['firstName'], 
          :villageName => patient['villageName'], 
          :familyName => patient['familyName'], 
          :age => patient['age'], 
          :sex => patient['sex'],
          :label => patient['label']
          )
        @currentPatient.save
        @currentPatient.reload
      else
        Patient.create!(
          :patientId => patient['patientId'], 
          :firstName => patient['firstName'],
          :villageName => patient['villageName'],
          :familyName => patient['familyName'],
          :age => patient['age'],
          :sex => patient['sex'],
          :label => patient['label'])
      end
    end

  @response = {
    :result => 'true'
  }

  render json:@response
  rescue => error
      @response = {
        :result => 'false',
        :data => 'Patient not found, creating one'
      }
      render json:@response
    end
 end
 
  def visits
    begin
      postParams = JSON.parse(params[:params]);

      if(!postParams.has_key?('access_token'))
        @response = {
          :result => 'false',
          :data => 'Missing access_token'
        }
        render json:@response
        return
      end
      isAuthenticated(postParams['access_token'])     
      if(postParams.has_key?('Timestamp'))
        @timestamp = Time.at(postParams['Timestamp'])
        @lowest = Time.at(-2146949393)
        if (@timestamp < @lowest)
          @timestamp = @lowest                
        end
        @visits = Visit.select("assessment,\"bloodPressure\",charityid,condition,\"conditionTitle\",\"diagnosisTitle\",\"doctorId\"
        ,\"doctorIn\",\"doctorOut\",\"heartRate\",\"medicationNotes\",\"nurseId\",observation,\"patientId\",respiration,
        temperature,\"triageIn\",\"triageOut\",\"visitationId\",weight").where("updated_at > ?",@timestamp)
      else
        @visits = Visit.select("assessment,\"bloodPressure\",charityid,condition,\"conditionTitle\",\"diagnosisTitle\",\"doctorId\"
        ,\"doctorIn\",\"doctorOut\",\"heartRate\",\"medicationNotes\",\"nurseId\",observation,\"patientId\",respiration,
        temperature,\"triageIn\",\"triageOut\",\"visitationId\",weight")
      end
      @response = {
        :result => 'true',
        :data => @visits
      }

      render json: @response

    rescue => error
      @response = {
        :result => 'false',
        :data => 'Not found any visit'
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
          :data => 'Missing access_token'
        }
        render json:@response
        return
      end
      isAuthenticated(postParams['access_token'])   
      @visits = postParams['Visitations']
      @visits.each do |visit|
        
      if(!visit.has_key?('weight'))
        visit['weight'] = nil
      elsif(!visit.has_key?('heartRate'))
        visit['heartRate'] = nil
      elsif(!visit.has_key?('temperature'))
        visit['temperature'] = nil
      elsif(!visit.has_key?('observation'))
        visit['observation'] = nil
      elsif(!visit.has_key?('assessment'))
        visit['assessment'] = nil
      elsif(!visit.has_key?('nurseId'))
        visit['nurseId'] = nil
      elsif(!visit.has_key?('conditionTitle'))
        visit['conditionTitle'] = nil
      elsif(!visit.has_key?('respiration'))
        visit['respiration'] = nil
      elsif(!visit.has_key?('patientId'))
        visit['patientId'] = nil
      elsif(!visit.has_key?('doctorOut'))
        visit['doctorOut'] = nil
      elsif(!visit.has_key?('condition'))
        visit['condition'] = nil
      elsif(!visit.has_key?('triageIn'))
        visit['triageIn'] = nil
      elsif(!visit.has_key?('medicationNotes'))
        visit['medicationNotes'] = nil
      elsif(!visit.has_key?('visitationId'))
        @response = {
          :result => 'false',
          :data => 'Missing visit id - Param ["visitationId"]'
        }
        render json:@response
        return
      elsif(!visit.has_key?('triageOut'))
        visit['triageOut'] = nil
      elsif(!visit.has_key?('bloodPressure'))
        visit['bloodPressure'] = nil
      elsif(!visit.has_key?('charityid'))
        visit['charityid'] = nil
      elsif(!visit.has_key?('diagnosisTitle'))
        visit['diagnosisTitle'] = nil
      elsif(!visit.has_key?('doctorId'))
        visit['doctorId'] = nil
      elsif(!visit.has_key?('doctorIn'))
        visit['doctorIn'] = nil
      end
      
      if(Visit.find(visit['visitationId']) rescue nil)
        @currentVisit = Visit.find(visit['visitationId'])
        @currentVisit.update_attributes(
        :weight => visit['weight'], 
        :heartRate => visit['heartRate'], 
        :temperature => visit['temperature'], 
        :observation => visit['observation'], 
        :assessment => visit['assessment'], 
        :nurseId => visit['nurseId'], 
        :conditionTitle => visit['conditionTitle'], 
        :respiration => visit['respiration'], 
        :patientId => visit['patientId'], 
        :doctorOut => visit['doctorOut'], 
        :condition => visit['condition'], 
        :triageIn => visit['triageIn'], 
        :medicationNotes => visit['medicationNotes'], 
        :triageOut => visit['triageOut'], 
        :bloodPressure => visit['bloodPressure'], 
        :charityid => visit['charityid'],
        :doctorIn => visit['doctorIn'], 
        :diagnosisTitle => visit['diagnosisTitle'], 
        :doctorIn => visit['doctorIn']
        )
        @currentVisit.save
        @currentVisit.reload
      else
        Visit.create!(
          :visitationId => visit['visitationId'], 
          :weight => visit['weight'], 
          :heartRate => visit['heartRate'], 
          :temperature => visit['temperature'], 
          :observation => visit['observation'], 
          :assessment => visit['assessment'], 
          :nurseId => visit['nurseId'], 
          :conditionTitle => visit['conditionTitle'], 
          :respiration => visit['respiration'], 
          :patientId => visit['patientId'], 
          :doctorOut => visit['doctorOut'], 
          :condition => visit['condition'], 
          :triageIn => visit['triageIn'], 
          :medicationNotes => visit['medicationNotes'], 
          :triageOut => visit['triageOut'], 
          :bloodPressure => visit['bloodPressure'], 
          :charityid => visit['charityid'],
          :doctorIn => visit['doctorIn'], 
          :diagnosisTitle => visit['diagnosisTitle'], 
          :doctorIn => visit['doctorIn']
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
          :data => 'Visit not found, creating one'
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
        :data => 'Missing access_token'
      }
      render json:@response
      return
    end
    isAuthenticated(postParams['access_token'])   
    if(postParams.has_key?('Timestamp'))
      @timestamp = Time.at(postParams['Timestamp'])
      @lowest = Time.at(-2146949393)
      if (@timestamp < @lowest)
        @timestamp = @lowest                
      end
      @prescriptions = Prescription.select("instructions,\"medicationId\",\"medName\",\"prescribedTime\",\"prescriptionId\",\"timeOfDay\",\"visitationId\",\"tabletPerDay\",charityid").where("updated_at > ?",@timestamp)
    else
      @prescriptions = Prescription.select("instructions,\"medicationId\",\"medName\",\"prescribedTime\",\"prescriptionId\",\"timeOfDay\",\"visitationId\",\"tabletPerDay\",charityid")
    end
    @response = {
      :result => 'true',
      :data => @prescriptions
    }

    render json: @response

  rescue
    @response = {
      :result => 'false',
      :data => 'Not found any prescription'
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
            :data => 'Missing access_token'
          }
          render json:@response
          return
        end
        isAuthenticated(postParams['access_token'])   
        @prescriptions = postParams['Prescriptions']
        @prescriptions.each do |prescription|
                
        if(!prescription.has_key?('medicationId'))
          prescription['medicationId'] = nil
        elsif(!prescription.has_key?('charityid'))
           prescription['charityid'] = nil
        elsif(!prescription.has_key?('instructions'))
          prescription['instructions'] = nil
        elsif(!prescription.has_key?('medName'))
          prescription['medName'] = nil
        elsif(!prescription.has_key?('prescribedTime'))
          prescription['prescribedTime'] = nil
        elsif(!prescription.has_key?('prescriptionId'))
          @response = {
            :result => 'false',
            :data => 'Missing prescription id - Param ["prescriptionId"]'
          }
          render json:@response
          return
        elsif(!prescription.has_key?('timeOfDay'))
          prescription['timeOfDay'] = nil
        elsif(!prescription.has_key?('visitationId'))
          prescription['visitationId'] = nil
        elsif(!prescription.has_key?('tabletPerDay'))
          prescription['tabletPerDay'] = nil
        end
  
        if (Prescription.find(prescription['prescriptionId']) rescue nil)
          @currentPrescription = Prescription.find(prescription['prescriptionId'])
          @currentPrescription.update_attributes(:medicationId => prescription['medicationId'], :charityid => prescription['charityid'], :instructions => prescription['instructions'], :medName => prescription['medName'], :prescribedTime => prescription['prescribedTime'], :visitationId => prescription['visitationId'],:timeOfDay => prescription['timeOfDay'], :tabletPerDay => prescription['tabletPerDay'])
          @currentPrescription.save
          @currentPrescription.reload
        else
          Prescription.create!(
            :prescriptionId => prescription['prescriptionId'],
            :visitationId => prescription['visitationId'],
            :medicationId => prescription['medicationId'], 
            :charityid => prescription['charityid'],
            :instructions => prescription['instructions'], 
            :medName => prescription['medName'], 
            :prescribedTime => prescription['prescribedTime'], 
            :visitationId => prescription['visitationId'], 
            :timeOfDay => prescription['timeOfDay'], 
            :tabletPerDay => prescription['tabletPerDay'])
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
          :data => 'Prescription not found, creating one'
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
          :data => 'Missing access_token'
        }
        render json:@response
        return
      end
      isAuthenticated(postParams['access_token'])
      @medications = Medication.select("dosage,\"medicationId\",expiration,\"medName\",\"numContainers\",\"tabletsContainer\",total").where("status = ?",1)

      @response = {
        :result => 'true',
        :data => @medications
      }

      render json: @response

    rescue => error
      @response = {
        :result => 'false',
        :data => 'Not found any medication'
      }

      render json: @response
    end
  end
end