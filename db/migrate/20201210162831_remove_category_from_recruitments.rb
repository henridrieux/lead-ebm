class RemoveCategoryFromRecruitments < ActiveRecord::Migration[6.0]
  def change
    remove_reference :recruitments, :category, null: false, foreign_key: true
  end
end
