class AddPlanToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :plan, :integer, default: 0
  end
end
