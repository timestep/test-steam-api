class AddDataToMatch < ActiveRecord::Migration
  def change
  	add_column :matches, :data, :text
  end
end
