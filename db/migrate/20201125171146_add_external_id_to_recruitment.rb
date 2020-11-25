class AddExternalIdToRecruitment < ActiveRecord::Migration[6.0]
  def change
    add_column :recruitments, :external_id, :string
  end
end
