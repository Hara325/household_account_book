class CreateHouseholds < ActiveRecord::Migration[5.0]
  def change
    create_table :households do |t|
      t.date :use_date
      t.integer :category_id
      t.integer :cost
      t.text :memo
      t.string :use
      t.integer :user_id

      t.timestamps
    end
  end
end
