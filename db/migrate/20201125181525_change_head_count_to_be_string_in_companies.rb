class ChangeHeadCountToBeStringInCompanies < ActiveRecord::Migration[6.0]
  def change
    change_column :companies, :head_count, :string
  end
end
