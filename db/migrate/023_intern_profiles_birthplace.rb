class InternProfilesBirthplace < ActiveRecord::Migration
  def self.up
    
    add_column :intern_profiles, :birthplace, :string, :limit => 25
    add_column :intern_profiles, :birthmonth, :string, :limit => 10
    
    add_column :intern_profiles, :intention, :string, :limit => 300
    add_column :intern_profiles, :skill, :string, :limit => 300
    add_column :intern_profiles, :experience, :string, :limit => 600
    
    add_column :intern_profiles, :desc, :string, :limit => 300
    
  end

  def self.down
    
    remove_column :intern_profiles, :desc
    
    remove_column :intern_profiles, :experience
    remove_column :intern_profiles, :skill
    remove_column :intern_profiles, :intention
    
    remove_column :intern_profiles, :birthmonth
    remove_column :intern_profiles, :birthplace
    
  end
end
