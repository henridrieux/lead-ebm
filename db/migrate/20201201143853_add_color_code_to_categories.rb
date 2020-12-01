class AddColorCodeToCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :color_code, :string
  end
end
