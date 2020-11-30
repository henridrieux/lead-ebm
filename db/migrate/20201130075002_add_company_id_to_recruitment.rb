class AddCompanyIdToRecruitment < ActiveRecord::Migration[6.0]
  def change
    add_reference :recruitments, :company, foreign_key: true
  end
end
