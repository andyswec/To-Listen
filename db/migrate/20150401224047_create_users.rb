class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :image, null: false
      t.string :spotify_id, index: true, unique: true
      t.string :spotify_access_token
      t.string :spotify_refresh_token

      t.timestamps null: false
    end
  end
end
