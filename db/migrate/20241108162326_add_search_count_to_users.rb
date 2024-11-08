class AddSearchCountToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :search_count, :integer, default: 0
  end
end
