class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.date :due_date
      t.string :status, null: false, default: 'pending'
      t.integer :priority, null: false, default: 2
      t.boolean :auto_generated, null: false, default: false
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :tasks, :due_date
    add_index :tasks, :status
  end
end
