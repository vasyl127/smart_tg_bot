class CreateErrors < ActiveRecord::Migration[7.0]
  def change
    create_table :errors do |t|
      t.string :name
      t.string :telegram_id
      t.string :message
      t.string :error
      t.string :error_full_message

      t.timestamps
    end
  end
end
