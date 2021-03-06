class AddIndexsl < ActiveRecord::Migration
  def up
    add_index :users,:userid ,unique: true
    add_index :appusers, :appuserid, unique: true
    add_index :charities, :charityid , unique: true
    add_index :medications, :medId, unique: true
    add_index :patients, :patientId, unique: true
    add_index :prescriptions, :prescriptionId, unique: true
    add_index :visits, :visitationId, unique: true
    add_index :serials, :serialId, unique: true
  end

  def down
  end
end
