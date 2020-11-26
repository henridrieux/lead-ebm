class UpdateActivitiesToText < ActiveRecord::Migration[6.0]
  def change
    change_column :companies, :activities, :text
  end
end
