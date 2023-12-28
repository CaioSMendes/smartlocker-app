class AddAllocatedKeysToLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :logs, :allocated_keys, :text
  end
end
