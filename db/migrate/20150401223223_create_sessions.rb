class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions, id: false do |t|
      t.string :id, null: false, unique: true, primary_key: true

      t.timestamps null: false
    end
  end
end

