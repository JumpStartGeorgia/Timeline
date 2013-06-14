class CreateEvents < ActiveRecord::Migration
  def up
    create_table :events do |t|
      t.string :event_type
      t.datetime :start_date
      t.datetime :end_date
      t.string :tag

      t.timestamps
    end

    Event.create_translation_table! :headline => :string, :story => :text, :media => :string, :credit => :string, :caption => :string

  end


  def down
    Event.drop_translation_table!
    drop_table :events
  end
end
