module CorporationsHelper

  def fill_corporation_profile(profile, params)
    profile.email = params[:email] && params[:email].strip
    profile.phone = params[:phone] && params[:phone].strip
    profile.contact = params[:contact] && params[:contact].strip
    profile.contact_gender = case params[:contact_gender]
      when "true"
        true
      when "false"
        false
      else
        nil
    end
    profile.contact_title = params[:contact_title] && params[:contact_title].strip
    
    profile.business_scope = params[:business_scope] && params[:business_scope].strip
    profile.job_district_id = params[:job_district] && params[:job_district].strip
    profile.address = params[:address] && params[:address].strip
    profile.zip = params[:zip] && params[:zip].strip
    profile.website = params[:website] && params[:website].strip
    
    profile.nature_id = params[:nature]
    profile.size_id = params[:size]
    profile.industry_category_id = params[:industry_category]
    profile.industry_id = params[:industry]
    profile.province_id = params[:province]
    profile.city_id = params[:city]
    
    profile.desc = params[:desc] && params[:desc].strip
  end
  
  
  def fill_corporation_job(job, params)
    job.name = params[:name] && params[:name].strip
    job.category_class_id = params[:job_category_class]
    job.category_id = params[:job_category]
    job.manager = params[:manager] && params[:manager].strip
    job.desc = params[:desc] && params[:desc].strip
    job.district_id = params[:job_district]
    job.place = params[:place] && params[:place].strip
    job.salary = params[:salary] && params[:salary].strip
    job.welfare = params[:welfare] && params[:welfare].strip
    job.number = params[:number] && params[:number].strip
    job.interview_number = params[:interview_number] && params[:interview_number].strip
    
    
    job.begin_at = params[:begin_at] && params[:begin_at].strip
    job.period_id = params[:job_period]
    job.workday_id = params[:job_workday]
    job.edu_level_id = params[:edu_level]
    job.graduation_id = params[:job_graduation]
    job.gender = case params[:gender]
      when "true"
        true
      when "false"
        false
      else
        nil
    end
    job.major_id = params[:job_major]
    job.requirement = params[:requirement] && params[:requirement].strip
    job.recruit_end_at = params[:recruit_end_at] && params[:recruit_end_at].strip
  end
  
  
  def count_intern_log(school_id, group_field, group_values, filters)
    with = {}
    with[group_field] = group_values unless group_values.nil?
    
    InternLog.period_group_counts(
      school_id, Date.parse(InternLog.intern_begin_at), Date.today,
      :group_by => group_field.to_s,
      :group_function => :attr,
      :with => with.merge(filters)
    ).inject({}) { |hash, record|
      hash[record[1]["@groupby"]] = record[1]["@count"]
      hash
    }
  end
  
  class InternLogCounts
    def self.ordered_keys
      [:aii, :rii, :irp, :irf, :irm, :ie, :il, :if]
    end
    def ordered_keys
      self.class.ordered_keys
    end
    
    def self.each_by_key(hash, &block)
      ordered_keys.each do |key|
        block.call(key, hash[key])
      end
    end
    def each_by_key(hash, &block)
      self.class.each_by_key(hash, &block)
    end
    
    def self.filters
      {
        :aii => {:event_id => 10, :result_id => 10},
        :rii => {:event_id => 10, :result_id => 20},
        :irp => {:event_id => 20, :result_id => 30},
        :irf => {:event_id => 20, :result_id => 40},
        :irm => {:event_id => 20, :result_id => 50},
        :ie => {:event_id => 30, :result_id => 70},
        :il => {:event_id => 30, :result_id => 80},
        :if => {:event_id => 30, :result_id => 90}
      }
    end
    def filters
      self.class.filters
    end
    def self.each_filter(&block)
      self.each_by_key(self.filters, &block)
    end
    def each_filter(&block)
      self.class.each_filter(&block)
    end
    
    def self.titles
      {
        :aii => "接受面试通知",
        :rii => "拒绝面试通知",
        :irp => "面试成功",
        :irf => "面试失败",
        :irm => "没去面试",
        :ie => "实习结束留任",
        :il => "实习中流动",
        :if => "实习中劝退"
      }
    end
    def titles
      self.class.titles
    end
    def self.each_title(&block)
      self.each_by_key(self.titles, &block)
    end
    def each_title(&block)
      self.class.each_title(&block)
    end
    
    def self.postfix
      "_counts"
    end
    
    def self.counts_field_name(key)
      "#{key}#{self.postfix}"
    end
    def counts_field_name(key)
      self.class.counts_field_name(key)
    end
    
    filters.each do |key, value|
      attr_reader key
      attr_reader "#{key}#{self.postfix}".to_sym
    end
    
    def initialize(count_proc, params = {})
      filters.each do |key, value|
        needed = (params == :all) || (params[key] == "true")
        self.instance_variable_set("@#{key}", needed)
        self.instance_variable_set(
          "@#{self.counts_field_name(key)}",
          needed ? count_proc.call(filters[key]) : {}
        )
      end
    end
    
    def get_counts(key)
      send(counts_field_name(key))
    end
  end
  def prepare_intern_log_counts(count_proc, params = :all)
    InternLogCounts.new(count_proc, params)
  end
  
end
