class AddUrlIconToEvent < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :url_icon, :text
  end
end
