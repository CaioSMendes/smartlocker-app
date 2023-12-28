class AddPositionsTextToLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :logs, :positions_text, :text
  end
end
