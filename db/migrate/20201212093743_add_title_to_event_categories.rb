class AddTitleToEventCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :event_categories, :title, :string
  end
end
