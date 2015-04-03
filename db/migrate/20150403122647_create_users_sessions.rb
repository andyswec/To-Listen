class CreateUsersSessions < ActiveRecord::Migration
  def change
    create_table :users_sessions, id: false do |t|
      t.references :user, null: false, references: :users, index: true
      t.references :session, type: :string, null: false, references: :sessions, index: true

      t.timestamps null: false
    end

    add_index :users_sessions, [:user_id, :session_id], unique: true
    add_foreign_key :users_sessions, :users
    add_foreign_key :users_sessions, :sessions
  end
end