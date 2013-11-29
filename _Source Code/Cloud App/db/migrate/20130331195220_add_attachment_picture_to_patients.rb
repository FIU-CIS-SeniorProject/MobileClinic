class AddAttachmentPictureToPatients < ActiveRecord::Migration
  def self.up
    change_table :patients do |t|
      t.attachment :picture
    end
  end

  def self.down
    drop_attached_file :patients, :picture
  end
end
