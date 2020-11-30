class AddQueryParamsToEvent < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :query_params, :string
  end
end
