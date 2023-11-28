class CreateKeylockers < ActiveRecord::Migration[7.0]
  def change
    create_table :keylockers do |t|
      t.string :owner
      t.string :nameDevice
      t.string :ipAddress
      t.string :status

      t.timestamps
    end
  end
end
