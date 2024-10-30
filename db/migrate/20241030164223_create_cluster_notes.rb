class CreateClusterNotes < ActiveRecord::Migration[7.1]
  def change
    create_table :cluster_notes do |t|
      t.references :cluster, null: false, foreign_key: true
      t.references :note, null: false, foreign_key: true

      t.timestamps
    end
  end
end
