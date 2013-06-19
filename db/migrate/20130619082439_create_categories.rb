class CreateCategories < ActiveRecord::Migration
  def up
    create_table :categories do |t|
      t.integer :type_id

      t.timestamps
    end

    add_index :categories, :type_id

    Category.create_translation_table! :name => :string, :permalink => :string
    add_index :category_translations, :name

  end

  def down
    drop_table :categories
    Category.drop_translation_table!
  end

end
