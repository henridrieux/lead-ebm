class AddManagerBirthYearToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :manager_birth_year, :integer
  end
end
