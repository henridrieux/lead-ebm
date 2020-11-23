class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.references :category, null: false, foreign_key: true
      t.string :company_name
      t.string :SIRET
      t.string :SIREN
      t.date :creation_date
      t.integer :registered_capital
      t.string :legal_structure
      t.string :naf_code
      t.string :activities
      t.string :zip_code
      t.string :address
      t.string :manager_name
      t.integer :head_count
      t.string :rcs_inscription

      t.timestamps
    end
  end
end
