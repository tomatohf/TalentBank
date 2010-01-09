class Notices < ActiveRecord::Migration
  def self.up
    
    create_table :notices, :force => true do |t|
      t.column :account_type_id, :integer, :limit => 1
      t.column :account_id, :integer
      
      t.column :type_id, :integer, :limit => 2
      t.column :read, :boolean, :default => false
      
      t.column :content, :string
      
      t.column :updated_at, :datetime
    end
    add_index :notices, [:account_type_id, :account_id, :read]
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO notices (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM notices WHERE id = 10000")
    
    
    create_table :requests, :force => true do |t|
      t.column :account_type_id, :integer, :limit => 1
      t.column :account_id, :integer
      
      t.column :requester_type_id, :integer, :limit => 1
      t.column :requester_id, :integer
      
      t.column :type_id, :integer, :limit => 2
      t.column :target_id, :integer
      t.column :data, :string
      
      t.column :updated_at, :datetime
    end
    add_index :requests, [:account_type_id, :account_id, :type_id, :target_id]
    add_index :requests, [:requester_type_id, :requester_id, :type_id, :target_id]
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO requests (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM requests WHERE id = 10000")
    
  end

  def self.down
    
    drop_table :requests
    
    drop_table :notices
    
  end
end
