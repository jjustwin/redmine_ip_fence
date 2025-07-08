class AddIpFieldsToAttachments < ActiveRecord::Migration[5.2]
  def change
    change_table :attachments do |t|
      t.string :ip
      t.boolean :is_sensitive, default: false
    end
  end
end
