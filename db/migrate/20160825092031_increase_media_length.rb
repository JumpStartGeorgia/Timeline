class IncreaseMediaLength < ActiveRecord::Migration
  def up
    change_column :event_translations, :media, :string, limit: 1000
  end

  def down
    change_column :event_translations, :media, :string, limit: 255
  end
end
