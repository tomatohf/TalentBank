class TeachersController < ApplicationController
  
  before_filter :check_login_for_teacher
  
  before_filter :check_active, :only => [:update, :update_password]
  
  before_filter :check_teacher
  
  before_filter :check_teacher_revision, :only => [:revisions]
  
  before_filter :check_teacher_statistic, :only => [:refresh_index]
  
  
  def show
    
  end
  
  
  def edit

  end
  
  def update
    @teacher.name = params[:name] && params[:name].strip
    @teacher.email = params[:email] && params[:email].strip
    
    if @teacher.save
      flash.now[:success_msg] = "修改成功, 信息已更新"
    else
      flash.now[:error_msg] = "操作失败, 再试一次吧"
    end
    
    render :action => "edit"
  end
  
  
  def edit_password

  end
  
  def update_password
    current_password = params[:current_password]
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    
    changed = (@teacher.password == current_password)
    
    if changed
      @teacher.password = password
      @teacher.password_confirmation = password_confirmation
      if @teacher.save
        flash.now[:success_msg] = "修改成功, 密码已更新"
      end
    else
      flash.now[:error_msg] = "修改失败, 当前密码 错误"
    end
    
    render :action => "edit_password"
  end
  
  
  def revisions
    teacher_account_type_id = AccountType.find_by(:name, "teachers")[:id]
    revision_select_fields = "id, resume_id, teacher_id, created_at"
    comment_select_fields = "id, resume_id, account_type_id, account_id, created_at"
    
    @date = begin
      Date.parse(params[:date])
    rescue
      last_revision = ResumeRevision.find(
        :first,
        :select => revision_select_fields,
        :conditions => ["teacher_id = ?", @teacher.id],
        :order => "created_at DESC"
      )
      last_comment = ResumeComment.find(
        :first,
        :select => comment_select_fields,
        :conditions => [
          "account_type_id = ? and account_id = ?",
          teacher_account_type_id,
          @teacher.id
        ],
        :order => "created_at DESC"
      )
      
      last_revision_date = last_revision && last_revision.created_at.to_date
      last_comment_date = last_comment && last_comment.created_at.to_date
      last_date = last_revision_date
      if !last_date || (last_comment_date && last_comment_date > last_date)
        last_date = last_comment_date
      end
      last_date ||= Date.today
      last_date
    end
    
    revisions = ResumeRevision.find(
      :all,
      :select => revision_select_fields,
      :conditions => ["teacher_id = ? and created_at BETWEEN ? and ?",
        @teacher.id,
        @date,
        1.second.ago(1.day.since(@date))
      ],
      :order => "created_at DESC"
    )
    comments = ResumeComment.find(
      :all,
      :select => comment_select_fields,
      :conditions => [
        "account_type_id = ? and account_id = ? and created_at BETWEEN ? and ?",
        teacher_account_type_id,
        @teacher.id,
        @date,
        1.second.ago(1.day.since(@date))
      ],
      :order => "created_at DESC"
    )
    
    @operations = (revisions + comments).group_by { |r_or_c| r_or_c.resume_id }
    @resumes = (@operations.keys.size > 0) && Resume.find(
      :all,
      :conditions => ["id in (?)", @operations.keys],
      :include => [:student]
    ).inject({}) do |hash, resume|
			hash[resume.id] = resume
			hash
		end
  end
  
  
  def refresh_index
    if request.post?
      sep = "\n\n" + ("-" * 100) + "\n\n"
      @output = if params[:index] == "all"
        if Rails.env.production?
          `rake ts:in RAILS_ENV=production` + sep + `rake ts:in:delta RAILS_ENV=production`
        else
          `rake ts:in` + sep + `rake ts:in:delta`
        end
      elsif params[:index] == "delta"
        if Rails.env.production?
          `rake ts:in:delta RAILS_ENV=production`
        else
          `rake ts:in:delta`
        end
      else
        ""
      end
    end
  end
  
  
  private
  
  def check_teacher
    teacher_id = params[:id] && params[:id].strip
    jump_to("/errors/forbidden") unless (session[:account_id].to_s == teacher_id) && ((@teacher = Teacher.find(teacher_id)).school_id == School.get_school_info(@school.abbr)[0])
  end
  
  
  def check_teacher_revision
    jump_to("/errors/unauthorized") unless @teacher.revision
  end
  
  
  def check_teacher_statistic
    jump_to("/errors/unauthorized") unless @teacher.statistic
  end
  
end
