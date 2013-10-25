class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients, :id => false do |t|
      t.string :firstName
      t.string :familyName
      t.integer :sex
      t.string :villageName
      t.integer :age
      t.string :patientId

      t.timestamps

    end

  end
end
