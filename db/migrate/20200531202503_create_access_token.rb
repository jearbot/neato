class CreateAccessToken < ActiveRecord::Migration[5.2]
  def change
    create_table :access_tokens do |t|
      t.string
      t.timestamps
    end
  end
end
