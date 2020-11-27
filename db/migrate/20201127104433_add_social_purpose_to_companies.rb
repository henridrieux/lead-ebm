class AddSocialPurposeToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :social_purpose, :text
  end
end
