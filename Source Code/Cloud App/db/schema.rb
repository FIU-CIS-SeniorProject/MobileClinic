# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131201170442) do

  create_table "appusers", :primary_key => "appuserid", :force => true do |t|
    t.string   "userName"
    t.string   "password"
    t.string   "firstName"
    t.string   "lastName"
    t.string   "email"
    t.integer  "charityid"
    t.string   "charityName"
    t.integer  "userType"
    t.integer  "status"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "appusers", ["appuserid"], :name => "index_appusers_on_appuserid", :unique => true

  create_table "auths", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.string   "user_token"
    t.string   "expiration"
    t.string   "access_token"
    t.integer  "charityid"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "charities", :primary_key => "charityid", :force => true do |t|
    t.string   "name"
    t.integer  "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "charities", ["charityid"], :name => "index_charities_on_charityid", :unique => true

  create_table "medications", :primary_key => "medId", :force => true do |t|
    t.string   "dosage"
    t.date     "expiration"
    t.string   "medicationId"
    t.string   "medName"
    t.integer  "numContainers"
    t.integer  "tabletsContainer"
    t.integer  "total"
    t.integer  "status"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "medications", ["medId"], :name => "index_medications_on_medId", :unique => true

  create_table "patients", :id => false, :force => true do |t|
    t.integer  "age"
    t.string   "familyName"
    t.string   "firstName"
    t.string   "patientId"
    t.integer  "sex"
    t.string   "villageName"
    t.integer  "label"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "patients", ["patientId"], :name => "index_patients_on_patientId", :unique => true

  create_table "prescriptions", :id => false, :force => true do |t|
    t.string   "instructions"
    t.string   "medicationId"
    t.string   "medName"
    t.string   "prescribedTime"
    t.string   "prescriptionId"
    t.string   "timeOfDay"
    t.string   "visitationId"
    t.integer  "tabletPerDay"
    t.integer  "charityid"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "prescriptions", ["prescriptionId"], :name => "index_prescriptions_on_prescriptionId", :unique => true

  create_table "serials", :primary_key => "serialId", :force => true do |t|
    t.string   "serialnum"
    t.integer  "charityid"
    t.string   "charityName"
    t.integer  "status"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "serials", ["serialId"], :name => "index_serials_on_serialId", :unique => true

  create_table "users", :primary_key => "userid", :force => true do |t|
    t.string   "userName"
    t.string   "password_digest"
    t.string   "firstName"
    t.string   "lastName"
    t.string   "email"
    t.integer  "charityid"
    t.string   "question"
    t.string   "answer"
    t.integer  "userType"
    t.integer  "status"
    t.integer  "reset_password"
    t.string   "remember_token"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["userid"], :name => "index_users_on_userid", :unique => true

  create_table "visits", :id => false, :force => true do |t|
    t.string   "assessment"
    t.string   "bloodPressure"
    t.integer  "charityid"
    t.string   "condition"
    t.string   "conditionTitle"
    t.string   "diagnosisTitle"
    t.string   "doctorId"
    t.integer  "doctorIn"
    t.integer  "doctorOut"
    t.string   "heartRate"
    t.string   "medicationNotes"
    t.string   "nurseId"
    t.string   "observation"
    t.string   "patientId"
    t.string   "respiration"
    t.string   "temperature"
    t.integer  "triageIn"
    t.integer  "triageOut"
    t.string   "visitationId"
    t.float    "weight"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "visits", ["visitationId"], :name => "index_visits_on_visitationId", :unique => true

end
