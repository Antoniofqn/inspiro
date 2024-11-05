class AddSummaryToNotes < ActiveRecord::Migration[7.1]
  def change
    add_column :notes, :summary, :text
  end
end
