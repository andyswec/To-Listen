class MakeImageInUserOptional < ActiveRecord::Migration
  def change
    change_column_null :users, :image, true
  end
end
