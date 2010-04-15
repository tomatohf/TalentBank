# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)



# schools
School.create(:abbr => "qiaobutang", :password => Utils.generate_password("qiaobutang"))
School.create(:abbr => "shou", :password => Utils.generate_password("shou"))



# data only for development ...
school_id = School.get_school_info("qiaobutang")[0]
School.find(school_id).update_attribute(:password, "qiaobutangs")
Teacher.create(:uid => "tomato", :password => "tomato", :admin => true, :school_id => school_id)
Teacher.create(:uid => "wahaha", :password => "tomato", :admin => false, :school_id => school_id)
Corporation.create(:uid => "ibm", :password => "ibm", :allow_query => true, :school_id => school_id, :name => "国际商用机器")
Corporation.create(:uid => "ge", :password => "ge", :allow_query => false, :school_id => school_id, :name => "通用电器")
college_id_0 = College.data["qiaobutang"][0][:id]
Student.create(
  :school_id => school_id,
  :number => "11111",
  :password => "11111",
  :name => "小乔",
  :college_id => college_id_0,
  :major_id => Major.data[college_id_0][0][:id],
  :edu_level_id => EduLevel.data[0][:id],
  :graduation_year => 2010
)
Student.create(
  :school_id => school_id,
  :number => "33333",
  :password => "33333",
  :name => "小布",
  :college_id => college_id_0,
  :major_id => Major.data[college_id_0][0][:id],
  :edu_level_id => EduLevel.data[0][:id],
  :graduation_year => 2010
)
Student.create(
  :school_id => school_id,
  :number => "55555",
  :password => "55555",
  :name => "小堂",
  :college_id => college_id_0,
  :major_id => Major.data[college_id_0][0][:id],
  :edu_level_id => EduLevel.data[0][:id],
  :graduation_year => 2010
)
