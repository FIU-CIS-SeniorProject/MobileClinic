class CreateSerials < ActiveRecord::Migration
  def change
    create_table :serials, {:primary_key => :serialId} do |t|
      t.string  :serialnum, unique: true
      t.integer :charityid
      t.string  :charityName
      t.integer :status

      t.timestamps
    end
  end
end
