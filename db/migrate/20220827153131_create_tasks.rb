class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.integer :user_id
      t.string :name
      t.string :date_notice

      t.timestamps
    end
  end
end
