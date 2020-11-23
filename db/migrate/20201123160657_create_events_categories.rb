class CreateEventsCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :events_categories do |t|
      t.references :category, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
