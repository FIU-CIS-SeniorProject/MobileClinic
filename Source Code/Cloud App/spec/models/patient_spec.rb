# == Schema Information
#
# Table name: Patient
# 
#   t.string  "firstName"
#   t.string  "familyName"
#   t.integer "sex"
#   t.string  "villageName"
#   t.integer "age"
#   t.string  "picture"
#   t.string  "patientId"
# end

require 'spec_helper'

describe Patient do

   
    it "is invalid without a firstName"  do
    FactoryGirl.build(:patient, firstName: nil).should_not be_valid
    end 
    it "is invalid without a familyName" do
    FactoryGirl.build(:patient, familyName: nil).should_not be_valid
    end 
    it "is invalid without a sex" do
    FactoryGirl.build(:patient, sex: nil).should_not be_valid
    end 
    it "is invalid without a villageName" do
    FactoryGirl.build(:patient, villageName: nil).should_not be_valid
    end 
    it "is invalid without an age" do
    FactoryGirl.build(:patient, age: nil).should_not be_valid
    end 


    # Implementation of patient picture is still to be done
    
    
    it "returns a contact's full name as a string" do
        patient = FactoryGirl.build(:patient, firstName: "carlos", familyName: "corvaia")
        patient.name.should == "carlos corvaia"
    end
end
