class AddNotesToMedication < ActiveRecord::Migration
  def change
    add_column :medications, :notes, :string
  end
end
