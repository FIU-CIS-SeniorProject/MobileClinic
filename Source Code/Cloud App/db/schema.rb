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

ActiveRecord::Schema.define(:version => 20130423223018) do

  create_table "appusers", :id => false, :force => true do |t|
    t.string   "userName"
    t.string   "password"
    t.string   "firstName"
    t.string   "lastName"
    t.string   "email"
    t.integer  "userType"
    t.integer  "status"
    t.integer  "secondaryTypes"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "appusers", ["userName", "email"], :name => "index_appusers_on_userName_and_email", :unique => true

  create_table "auths", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.string   "user_token"
    t.string   "expiration"
    t.string   "access_token"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "medications", :id => false, :force => true do |t|
    t.integer  "medId"
    t.string   "name"
    t.integer  "numContainers"
    t.integer  "tabletsPerContainer"
    t.integer  "expiration"
    t.integer  "doseOfTablets"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "notes"
  end

  add_index "medications", ["medId"], :name => "index_medications_on_medId", :unique => true

  create_table "patients", :id => false, :force => true do |t|
    t.string   "firstName"
    t.string   "familyName"
    t.integer  "sex"
    t.string   "villageName"
    t.integer  "age"
    t.string   "patientId"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
  end

  add_index "patients", ["patientId"], :name => "index_patients_on_patientId", :unique => true

  create_table "prescriptions", :id => false, :force => true do |t|
    t.integer  "prescribedAt"
    t.integer  "medId"
    t.integer  "tabletsPerDay"
    t.string   "timeOfDay"
    t.string   "instruction"
    t.integer  "vistitId"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "prescriptions", ["vistitId"], :name => "index_prescriptions_on_vistitId", :unique => true

  create_table "users", :id => false, :force => true do |t|
    t.string   "userName"
    t.string   "password_digest"
    t.string   "firstName"
    t.string   "lastName"
    t.string   "email"
    t.integer  "userType"
    t.integer  "status"
    t.string   "remember_token"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["userName", "email"], :name => "index_users_on_userName_and_email", :unique => true

  create_table "visits", :id => false, :force => true do |t|
    t.integer  "triageIn"
    t.float    "weight"
    t.string   "diagnosisTitle"
    t.text     "conditions"
    t.string   "bloodPressure"
    t.integer  "triageOut"
    t.integer  "doctorIn"
    t.integer  "doctorOut"
    t.string   "doctorId"
    t.string   "nurseId"
    t.string   "patientId"
    t.text     "observation"
    t.string   "heartRate"
    t.string   "respiration"
    t.string   "visitationId"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "visits", ["visitationId"], :name => "index_visits_on_visitationId", :unique => true

end
