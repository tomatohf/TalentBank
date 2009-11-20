class TeacherStatisticsController < ApplicationController
  
  Queries_Page_Size = 100
  
  
  layout "teachers"
  
  
  before_filter :check_login_for_teacher
  
  # before_filter :check_active, :only => []
  
  before_filter :check_teacher
  
  before_filter :check_teacher_statistic
  
  
  def index
    
  end
  
  
  def queries
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @corp_queries = CorpQuery.paginate(
      :page => page,
      :per_page => Queries_Page_Size,
      :order => "id DESC",
      :include => [:corporation]
    )
  end
  
  
  def resumes
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @viewed_resumes = CorpViewedResume.paginate(
      :page => page,
      :per_page => Queries_Page_Size,
      :order => "id DESC",
      :include => [:corporation, {:resume => [:student]}]
    )
  end
  
  
  private
  
  def check_teacher
    teacher_id = params[:teacher_id] && params[:teacher_id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == teacher_id) && ((@teacher = Teacher.find(teacher_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_teacher_statistic
    jump_to("/errors/unauthorized") unless @teacher.statistic
  end
  
end
