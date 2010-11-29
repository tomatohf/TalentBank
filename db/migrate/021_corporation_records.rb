class CorporationRecords < ActiveRecord::Migration
  def self.up
    
    create_table :corporation_records, :force => true do |t|
      t.column :corporation_id, :integer
      
      t.column :notes, :string, :limit => 500
      
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :corporation_records, [:corporation_id, :created_at]
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO corporation_records (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM corporation_records WHERE id = 10000")
    
  end

  def self.down
    
    drop_table :corporation_records
    
  end
end
