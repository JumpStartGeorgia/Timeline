class AddEventFile < ActiveRecord::Migration
  def change
    add_column :event_translations, :media_img_file_name, :string
    add_column :event_translations, :media_img_content_type, :string
    add_column :event_translations, :media_img_file_size, :integer
    add_column :event_translations, :media_img_updated_at, :datetime

    add_column :event_translations, :media_img_verified, :boolean, :default => false
  end
end
