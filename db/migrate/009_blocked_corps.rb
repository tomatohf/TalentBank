class BlockedCorps < ActiveRecord::Migration
  def self.up
    
    create_table :blocked_corps, :force => true do |t|
      t.column :student_id, :integer
      t.column :corporation_id, :integer
      
      t.column :updated_at, :datetime
    end
    add_index :blocked_corps, [:student_id, :corporation_id], :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO blocked_corps (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM blocked_corps WHERE id = 10000")

  end

  def self.down
    
    drop_table :blocked_corps
    
  end
end
