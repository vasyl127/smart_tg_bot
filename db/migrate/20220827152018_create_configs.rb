class CreateConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :configs do |t|
      t.integer :user_id
      t.string :locale, default: 'ua'
      t.string :telegram_step
      t.string :weather_notice, default: 'true'
      t.string :notice_sound, default: 'true'

      t.timestamps
    end
  end
end
