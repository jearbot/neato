class AddExpiresAtToAccessKey < ActiveRecord::Migration[5.2]
  def change
    add_column :access_tokens, :expires_at, :datetime
  end
end
