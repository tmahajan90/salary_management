class CreateSalaries < ActiveRecord::Migration[8.1]
  def change
    create_table :salaries do |t|
      t.references :employee, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, null: false
      t.date :effective_from, null: false
      t.date :effective_to
      t.text :notes

      t.timestamps
    end

    add_index :salaries, [:employee_id, :effective_from]
    add_index :salaries, :effective_to
  end
end
