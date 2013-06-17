class SplitDateFields < ActiveRecord::Migration
  def up
    change_column :events, :start_date, :date
    change_column :events, :end_date, :date

    add_column :events, :start_time, :time
    add_column :events, :end_time, :time
    

    add_index :events, [:start_date, :start_time], :name => 'idx_events_start'
    add_index :events, [:end_date, :end_time], :name => 'idx_events_end'
  end

  def down
    change_column :events, :start_date, :datetime
    change_column :events, :end_date, :datetime

    remove_column :events, :start_time, :time
    remove_column :events, :end_time, :time
    
    remove_index :events, [:start_date, :start_time]
    remove_index :events, [:end_date, :end_time]
  end
end
