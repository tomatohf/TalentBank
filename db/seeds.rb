# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)



# schools
School.create(:abbr => "qiaobutang", :password => "woshiqiaobutang")
School.create(:abbr => "shift", :password => Utils.generate_password("shift"))



# TO BE DELETED !!! ... only for development ...
school_id = School.get_school_info("shift")[0]
Teacher.create(:uid => "tomato", :password => "tomato", :admin => true, :school_id => school_id)
Teacher.create(:uid => "wahaha", :password => "tomato", :admin => false, :school_id => school_id)
college_id = College.data["shift"].first[:id]
Student.create(
  :school_id => school_id,
  :number => 11111,
  :password => 11111,
  :college_id => college_id,
  :college_id => Major.data[college_id].first[:id],
  :edu_level_id => EduLevel.data.first[:id],
  :enter_year => 2006
)
