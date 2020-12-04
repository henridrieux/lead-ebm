class AddColumnsToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :fusion_date, :date
    add_column :companies, :second_headquarter_date, :date
    add_column :companies, :website_date, :date
  end
end
