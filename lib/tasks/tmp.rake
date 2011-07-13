namespace :tmp do
  
  task :info => :environment do
    students = Student.find(
      :all,
      :conditions => [
        "id in (?)",
        [
          1656,2774,962,571,2976,2669,2621,1779,1206,2739,2577,2336,3991,3355,3778,
          4087,3536,1333,3238,3299,1791,3276,3263,2042,4002,3998,3972,2122,578,2066,
          1832,2757,2361,2814,3979,692,1325,1288,3338,3305,3271,1450,2496,3729,3005,
          2137,3783,2425,2116,980,3885,3857,3952,2204,4051,2754,3289,2599,2834,3351
        ]
      ],
      :include => [:profile, :intern_profile, {:intern_logs => [{:job => :corporation}]}]
    )
    
    csv_data = FasterCSV.generate do |csv|
      csv << ["学号", "姓名", "性别", "大学", "学历", "毕业时间", "相关专业", "其他信息", "最近实习记录公司", "最近实习记录岗位", "最近实习记录事件", "最近实习记录结果", "最近实习记录发生时间"]
      
      students.each do |student|
        profile = student.profile
				intern_profile = student.intern_profile
				logs = student.intern_logs
				
				university = University.find(student.university_id)
				edu_level = EduLevel.find(student.edu_level_id)
				job_major = JobMajor.find(intern_profile && intern_profile.major_id)
				
				log = logs.sort { |x, y|
				  x.occur_at <=> y.occur_at
				}.last
				event = log && InternLogEvent.find(log.event_id)
				result = event && InternLogEventResult.find(event[:id], log.result_id)
				job = log && log.job
				corporation = job && job.corporation
				occur_at = log && if log.occur_at.kind_of?(DateTime)
				  log.occur_at
			  else
			    log.occur_at.getlocal
		    end
				
        csv << [
          student.number,
          student.name,
          {true => "男", false => "女"}[profile && profile.gender],
          university && university[:name],
          edu_level && edu_level[:name],
          student.graduation_year,
          job_major && job_major[:name],
          intern_profile && intern_profile.desc,
          corporation && "#{corporation.id}   #{corporation.name}",
          job && "#{job.id}   #{job.name}",
          event && event[:name],
          result && result[:name],
          occur_at && occur_at.strftime("%Y-%m-%d %H:%M:%S")
        ]
      end
    end
    
    File.open("/home/tomato/temp/info.csv", "w") do |file|
      file.write(csv_data)
    end
  end
  
end
