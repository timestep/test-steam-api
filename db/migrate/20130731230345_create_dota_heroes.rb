class CreateDotaHeroes < ActiveRecord::Migration
  def change
    create_table :dota_heroes do |t|
      t.string :name

      t.timestamps
    end
  end
end
