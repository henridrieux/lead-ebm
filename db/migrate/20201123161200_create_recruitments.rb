class CreateRecruitments < ActiveRecord::Migration[6.0]
  def change
    create_table :recruitments do |t|
      t.references :category, null: false, foreign_key: true
      t.string :employer
      t.string :job_title
      t.string :contract_type
      t.integer :zip_code
      t.date :publication_date

      t.timestamps
    end
  end
end
