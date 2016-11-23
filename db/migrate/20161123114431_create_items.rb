class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.json :json_filed
      t.timestamps
    end
  end
end
