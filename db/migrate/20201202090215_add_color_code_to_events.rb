class AddColorCodeToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :color_code, :string
  end
end
