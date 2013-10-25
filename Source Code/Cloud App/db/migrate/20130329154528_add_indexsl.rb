class AddIndexsl < ActiveRecord::Migration
  def up
    add_index :users, [:userName, :email] ,unique: true
    add_index :appusers, [:userName,:email ], unique: true
    add_index :medications, :medId, unique: true
    add_index :patients, :patientId, unique: true
    add_index :prescriptions, :vistitId, unique: true
    add_index :visits, :visitationId, unique: true
  end

  def down
  end
end
