class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event_category, null: false, foreign_key: true
      t.date :start_date
      t.string :status

      t.timestamps
    end
  end
end
