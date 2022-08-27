class CreateCosts < ActiveRecord::Migration[7.0]
  def change
    create_table :costs do |t|
      t.integer :category_id
      t.string :name
      t.integer :value, default: 0
      t.string :ticket
      t.string :user_created

      t.timestamps
    end
  end
end
