class AddEmployerToRecruitment < ActiveRecord::Migration[6.0]
  def change
    add_column :recruitments, :employer_email, :string
    add_column :recruitments, :job_description, :text
    add_column :recruitments, :employer_phone, :string
    add_column :recruitments, :employer_name, :string
  end
end
