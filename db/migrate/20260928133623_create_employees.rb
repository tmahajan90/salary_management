class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :employee_code, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :department, null: false
      t.string :job_title, null: false
      t.string :country, null: false
      t.date :hire_date
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :employees, :employee_code, unique: true
    add_index :employees, :email, unique: true
    add_index :employees, :department
    add_index :employees, :country
    add_index :employees, :status
  end
end
