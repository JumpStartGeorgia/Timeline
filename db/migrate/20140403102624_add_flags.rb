class AddFlags < ActiveRecord::Migration
  def change
    add_column :events, :is_start_year_only, :boolean, :default => false
    add_column :events, :is_end_year_only, :boolean, :default => false
  end
end
