class RemoveTitleToEventCategories < ActiveRecord::Migration[6.0]
  def change
    remove_column :event_categories, :title
  end
end
