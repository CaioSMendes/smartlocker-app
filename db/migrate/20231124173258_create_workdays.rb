class CreateWorkdays < ActiveRecord::Migration[7.0]
  def change
    create_table :workdays do |t|
      t.string :dayofweek
      t.time :start
      t.time :end
      t.boolean :holiday
      t.references :employee, null: false, foreign_key: true

      t.timestamps
    end
  end
end
