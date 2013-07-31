class AddSteamapikeyToUser < ActiveRecord::Migration
  def change
  	add_column :users, :steamapikey, :string
  end
end
