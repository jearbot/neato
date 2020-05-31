class CreateRefreshTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :refresh_tokens do |t|
      t.string :key, null: false
      t.datetime :deleted_at
  
      t.timestamps
    end
  end
end
