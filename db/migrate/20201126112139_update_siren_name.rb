class UpdateSirenName < ActiveRecord::Migration[6.0]
  def change
    rename_column :companies, :SIREN, :siren
  end
end
