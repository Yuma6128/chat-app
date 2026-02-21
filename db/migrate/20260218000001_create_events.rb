class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description
      t.date :event_date, null: false
      t.string :category, null: false, default: 'other'
      t.string :status, null: false, default: 'upcoming'
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :events, :event_date
    add_index :events, :category
  end
end
