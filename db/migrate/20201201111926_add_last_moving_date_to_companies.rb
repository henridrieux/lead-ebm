class AddLastMovingDateToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :last_moving_date, :date
  end
end
