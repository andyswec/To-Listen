class StoreLastFmUserHash < ActiveRecord::Migration
  def change
    remove_foreign_key :users_sessions, column: :last_fm_id
    drop_table :last_fm_users

    create_table :last_fm_users, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.text :last_fm_hash

      t.timestamps null:false
    end

    add_foreign_key :users_sessions, :last_fm_users, column: 'last_fm_id'
  end
end
