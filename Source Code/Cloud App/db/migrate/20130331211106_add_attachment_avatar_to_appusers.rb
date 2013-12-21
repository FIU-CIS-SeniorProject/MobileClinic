class AddAttachmentAvatarToAppusers < ActiveRecord::Migration
  def self.up
    change_table :appusers do |t|
      t.attachment :avatar
    end
  end

  def self.down
    drop_attached_file :appusers, :avatar
  end
end
