class CreateScores < ActiveRecord::Migration[6.1]
  def change
    create_table :scores do |t|
      t.string :player, collation: 'NOCASE'
      t.integer :score
      t.datetime :time
    end
    add_index :scores, :time
    add_index :scores, :player
  end
end