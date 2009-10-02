class Teachers < ActiveRecord::Migration
  def self.up
    
    create_table :teachers, :force => true do |t|
      t.column :uid, :string, :limit => 25
      t.column :password, :string
      
      t.column :name, :string, :limit => 15
      t.column :email, :string
      
      t.column :school_id, :integer
      
      t.column :admin, :boolean, :default => false
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO teachers (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM teachers WHERE id = 10000")

  end

  def self.down
    
    drop_table :teachers
    
  end
end
