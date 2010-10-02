module StudentsHelper

  def fill_student_editable_fields(student, params)
    student.name = params[:name] && params[:name].strip
    
    student.university_id = params[:university_id]
    student.college_id = params[:college_id]
    student.major_id = params[:major_id]
    student.edu_level_id = params[:edu_level_id]
    student.graduation_year = params[:graduation_year]
  end
  
  
  def fill_student_intern_profile(profile, params)
    profile.begin_at = params[:begin_at] && params[:begin_at].strip
    profile.period_id = params[:job_period]
    profile.workday_id = params[:job_workday]
    profile.major_id = params[:job_major]
    profile.salary = params[:salary] && params[:salary].strip
  end
  
end
