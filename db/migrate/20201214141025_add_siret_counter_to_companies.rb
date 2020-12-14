class AddSiretCounterToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :siret_count, :integer
  end
end
