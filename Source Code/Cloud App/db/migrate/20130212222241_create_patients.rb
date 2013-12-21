class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients, :id => false do |t|
      t.integer  :age
      t.string   :familyName
      t.string   :firstName
      t.string   :patientId
      t.integer  :sex
      t.string   :villageName
      t.integer  :label

      t.timestamps
    end
  end
end
