class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :title
      t.string :description
      t.string :frequency
      t.string :query

      t.timestamps
    end
  end
end
