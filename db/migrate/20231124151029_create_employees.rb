class CreateEmployees < ActiveRecord::Migration[7.0]
  def change
    create_table :employees do |t|
      t.string :name
      t.string :lastname
      t.string :companyID
      t.string :phone
      t.string :function
      t.string :PIN
      t.string :pswdSmartlocker
      t.string :cardRFID
      t.string :status

      t.timestamps
    end
  end
end
