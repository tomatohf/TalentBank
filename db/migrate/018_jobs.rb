class Jobs < ActiveRecord::Migration
  def self.up
    
    create_table :jobs, :force => true do |t|
      t.column :corporation_id, :integer
      
      t.column :name, :string, :limit => 50
      t.column :category_class_id, :integer, :limit => 2
      t.column :category_id, :integer, :limit => 2
      
      t.column :manager, :string, :limit => 50
      
      t.column :desc, :string, :limit => 500
      
      t.column :district_id, :integer, :limit => 2
      t.column :place, :string, :limit => 200
      
      t.column :salary, :decimal
      
      t.column :welfare, :string, :limit => 300
      
      t.column :number, :integer, :limit => 2
      t.column :interview_number, :integer, :limit => 2
      
      
      t.column :begin_at, :datetime
      t.column :period_id, :integer, :limit => 2
      t.column :workday_id, :integer, :limit => 2
      t.column :edu_level_id, :integer, :limit => 2
      t.column :graduation_id, :integer, :limit => 2
      t.column :major_id, :integer, :limit => 2
      t.column :skill_id, :integer
      t.column :requirement, :string, :limit => 500
      t.column :recruit_end_at, :datetime
      
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :jobs, [:corporation_id, :created_at]
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO jobs (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM jobs WHERE id = 10000")
    
  end

  def self.down
    
    drop_table :jobs
    
  end
end
