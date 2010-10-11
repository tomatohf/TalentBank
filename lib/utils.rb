module Utils
  
  def self.generate_password(uid = "")
    uid.blank? ? "password" : uid
  end
  
  
  def self.lines(text, remove_empty = true)
    text.gsub!(/\r\n?/, "\n")
    lines = text.split(/\n/)
    lines.delete_if { |line| line.blank? } if remove_empty
    lines
  end
  
  
  def self.top_axis(max_value)
    top = %Q!#{max_value.to_s.first.to_i+1}#{"0"*(max_value.to_s.size-1)}!.to_i
    top < 10 ? 10 : top
  end
  
  
  def self.growth(a, b, n)
    return "N/A" if (b == 0)
    
    format = "%.#{n}f"
    "#{format % (((a-b)/b.to_f)*100)}%"
  end
  
  
  def self.percent(a, b, n)
    return "N/A" if (b == 0)
    
    format = "%.#{n}f"
    "#{format % ((a.to_f/b)*100)}%"
  end
  
  
  def self.step_period(from, to, step = :day)
    from, to = to, from if from > to
    
    periods = []
    
    this_step = from
    while this_step < to
      next_step = case step
      when :week
        # 0 means treat Monday as the first day of week
        # so ...
        # 6 means treat Sunday as the first day of week
        next_sunday = 6.days.since(
          begin
            Date.commercial(this_step.cwyear, this_step.cweek + 1, 1)
          rescue ArgumentError
            Date.commercial(this_step.cwyear + 1, 1, 1)
          end
        )
        # if Sunday, return next Sunday
        # if NOT Sunday, return this Sunday
        this_step.wday > 0 ? 1.week.ago(next_sunday) : next_sunday
      when :month
        begin
          Date.new(this_step.year, this_step.month + 1, 1)
        rescue ArgumentError
          Date.new(this_step.year + 1, 1, 1)
        end
      when :year
        Date.new(this_step.year + 1, 1, 1)
      else
        # treat as :day defaultly
        this_step.to_date.next
      end
      
      period_from, period_to = this_step, [1.day.ago(next_step), to].min
      periods << [period_from, period_to]
      yield(period_from, period_to) if block_given?
      
      this_step = next_step
    end
    
    if this_step == to
      periods << [this_step, to]
      yield(this_step, to) if block_given?
    end
    
    periods
  end
  
  
  def self.expand_cache_key(key)
    ActiveSupport::Cache.expand_cache_key(key, :views)
  end
  
  
  def self.deep_copy(object)
    Marshal::load(Marshal.dump(object))
  end
  
  
  def self.truncate_text(text, len, append = "...")
    return "" if text.nil?
    text.mb_chars.length > len ? text.mb_chars[0...(len - append.mb_chars.length)] + append : text
  end
  
  
  def self.get_unique_id
    now = Time.now
    "#{now.to_i}_#{now.usec}_#{Process.pid}"
  end
  
  
  module CountCacheable
    def self.included(including_model)
      
      def including_model.get_count(group_field_id)
        c = Rails.cache.read("#{self::CKP_count}_#{group_field_id}")
        unless c
          c = self.count(:conditions => self::Count_Cache_Group_Field ? ["#{self::Count_Cache_Group_Field} = ?", group_field_id] : [])

          Rails.cache.write("#{self::CKP_count}_#{group_field_id}", c, :expires_in => Cache_TTL[:long])
        end
        c
      end

      def including_model.increase_count_cache(group_field_id, count = 1)
        c = Rails.cache.read("#{self::CKP_count}_#{group_field_id}")
        if c
          updated_c = c.to_i + count

          Rails.cache.write("#{self::CKP_count}_#{group_field_id}", updated_c, :expires_in => Cache_TTL[:long])
        end
      end

      def including_model.decrease_count_cache(group_field_id, count = 1)
        c = Rails.cache.read("#{self::CKP_count}_#{group_field_id}")
        if c
          updated_c = c.to_i - count

          Rails.cache.write("#{self::CKP_count}_#{group_field_id}", updated_c, :expires_in => Cache_TTL[:long])
        end
      end

      def including_model.clear_count_cache(group_field_id)
        Rails.cache.delete("#{self::CKP_count}_#{group_field_id}")
      end
      
      
      including_model.after_destroy { |record|
        record.class.decrease_count_cache(record.send(record.class::Count_Cache_Group_Field))
      }

      including_model.after_create { |record|
        record.class.increase_count_cache(record.send(record.class::Count_Cache_Group_Field))
      }
      
    end
  end
  
  
  module UniqueBelongs
    def self.included(including_model)
      
      def including_model.get_record(*belongs_to_ids)
        record = self.find(
          :first,
          :conditions => [
            self::Belongs_To_Keys.collect { |key|
              "#{key} = ?"
            }.join(" and "),
            *belongs_to_ids
          ]
        )
        
        unless record
          init = {}
          self::Belongs_To_Keys.each_with_index do |key, i|
            init[key] = belongs_to_ids[i]
          end
          
          record = self.new(init)
        end
        
        record
      end
      
    end
  end
  
  
  # ActiveRecord::Base.serialize method leverages YAML
  # While YAML will translate Chinese to unicode,
  # which make the serialized string too long
  module FieldHashable
    def self.included(including_model)
      
      def including_model.hash_field(*fields)
        fields.each do |field|
          define_method("get_#{field}") {
            eval(self.send(field) || "") || {}
          }
          
          define_method("fill_#{field}") { |value|
            self.send("#{field}=", value.inspect)
          }
          
          define_method("update_#{field}") { |value|
            self.send("fill_#{field}", self.send("get_#{field}").merge(value))
          }
        end
      end
      
    end
  end
  
  
  module NotDeletable
    def self.included(including_model)
      
      including_model.before_destroy { |record|
        raise "Can NOT destroy #{record.class.name} model !"
      }
      
    end
  end
  
  
  module ActiveRecordHelpers
    def self.included(including_model)
      
      def including_model.try_find(*args)
        self.find(*args) rescue nil
      end
      
    end
  end
  
  
  module Searchable
    def self.included(including_model)
      
      including_model.const_set(:Overall_Index_Hour, 3)
      including_model.const_set(:Overall_Index_Minute, 58)
      
      including_model.const_set(:Search_Match_Mode, :extended)
      
      including_model.class_eval {
        
        define_method(:renew_updated_at) do |time|
          now = Time.now
          date = Time.local(now.year, now.month, now.mday, including_model::Overall_Index_Hour, including_model::Overall_Index_Minute)

          last_index_at = (now < date) ? 1.day.ago(date) : date

          if (last_index_at >= self.updated_at) && (time > last_index_at)
            self.updated_at = time
            self.save
          end
        end
        
      }
      
      
      def including_model.period_group_counts(school_id, from, to, options = {})
        from, to = to, from if from > to

        from_time = Time.local(from.year, from.month, from.mday, 0, 0, 0)
        to_time = Time.local(to.year, to.month, to.mday, 23, 59, 59)
        
        group_function = options[:group_function] || :attr
        
        search_args = {
          :with_attributes => true,
          
          :group_by => options[:group_by] || "updated_at",
          :group_function => group_function,
          # :match_mode => self::Search_Match_Mode,
          # :order => "updated_at ASC",
          :with => {
            :school_id => school_id,
            :updated_at => from_time..to_time
          }.merge(options[:with] || {})
        }
        search_args[:group_clause] = options[:group_clause] if options[:group_clause]
        if options[:limit]
          search_args[:page] = 1
          search_args[:per_page] = options[:limit]
        end
        search_args[:without] = options[:without] if options[:without]
        
        result = self.search_for_ids(search_args)
        
        result = result.inject({}) { |hash, record|
          hash[record[1]["@groupby"].to_s] = record[1]["@count"]
          hash
        } unless (group_function == :attr)
        
        result
      end
      
      
      def including_model.period_total_count(school_id, from, to, options = {})
        from, to = to, from if from > to

        from_time = Time.local(from.year, from.month, from.mday, 0, 0, 0)
        to_time = Time.local(to.year, to.month, to.mday, 23, 59, 59)
        
        search_args = {
          # :match_mode => self::Search_Match_Mode,
          # :order => "updated_at ASC",
          :with => {
            :school_id => school_id,
            :updated_at => from_time..to_time
          }.merge(options[:with] || {})
        }
        search_args[:without] = options[:without] if options[:without]
        
        self.search_count(search_args) || 0
      end
      
      
      def including_model.period_records(school_id, from, to, options = {})
        from, to = to, from if from > to

        from_time = Time.local(from.year, from.month, from.mday, 0, 0, 0)
        to_time = Time.local(to.year, to.month, to.mday, 23, 59, 59)
        
        self.search(
          :page => options[:page] || 1,
          :per_page => options[:per_page] || 10,
          :match_mode => self::Search_Match_Mode,
          :order => "updated_at DESC",
          :field_weights => {},
          :with => {
            :school_id => school_id,
            :updated_at => from_time..to_time
          }.merge(options[:with] || {}),
          :include => options[:includes] || []
        )
      end
      
    end
  end
  
  
  module InternWishHelpers
    def self.included(including_model)
      
      def including_model.list_from_student(student_id)
        self.find(
          :all,
          :conditions => ["student_id = ?", student_id]
        )
      end
      
      
      including_model.after_save { |wish|
        wish.student.renew_updated_at(wish.updated_at)
      }
      including_model.after_destroy { |wish|
        wish.student.renew_updated_at(Time.now)
      }
      
    end
  end

end
