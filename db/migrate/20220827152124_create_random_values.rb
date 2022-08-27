class CreateRandomValues < ActiveRecord::Migration[7.0]
  def change
    create_table :random_values do |t|
      t.integer :user_id
      t.string :value
      t.string :description

      t.timestamps
    end
  end
end
