class UpdateSiretName < ActiveRecord::Migration[6.0]
  def change
    rename_column :companies, :SIRET, :siret
  end
end
