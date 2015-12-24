class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :slug

      t.timestamps null: false
    end
  end
end
