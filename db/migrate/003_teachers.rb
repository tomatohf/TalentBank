class Teachers < ActiveRecord::Migration
  def self.up
    
    create_table :teachers, :force => true do |t|
      t.column :number, :string, :limit => 25
      t.column :password, :string
      
      t.column :school_id, :integer
      
      t.column :active, :boolean, :default => true
      t.column :enabled, :boolean, :default => true
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO students (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM students WHERE id = 10000")

  end

  def self.down
    
    drop_table :teachers
    
  end
end
