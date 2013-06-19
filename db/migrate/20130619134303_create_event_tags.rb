class CreateEventTags < ActiveRecord::Migration
  def change
    create_table :events_tags do |t|
      t.integer :category_id
      t.integer :event_id

      t.timestamps
    end

    add_index :events_tags, :category_id
    add_index :events_tags, :event_id
  end
end
