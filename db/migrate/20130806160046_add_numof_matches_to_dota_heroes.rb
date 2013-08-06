class AddNumofMatchesToDotaHeroes < ActiveRecord::Migration
  def change
  	add_column :dota_heroes, :numMatches, :integer, :default => 0
  end
end
