class CreateCharities < ActiveRecord::Migration
  def change
    create_table :charities, {:primary_key => :charityid}  do |t|
      t.string  :name
      t.integer :status

      t.timestamps
    end
  end
end
