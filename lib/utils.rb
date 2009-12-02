module Utils
  
  # !!! the method to generate initial password
  def self.generate_password(uid = "")
    "pass#{uid}word"
  end
  
  
  def self.lines(text, remove_empty = true)
    text.gsub!(/\r\n?/, "\n")
    lines = text.split(/\n/)
    lines.delete_if { |line| line.blank? } if remove_empty
    lines
  end
  
  
  def self.growth(a, b, n)
    return "N/A" if (b == 0)
    
    format = "%.#{n}f"
    "#{format % (((a-b)/b.to_f)*100)}%"
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
        c = Cache.get("#{self::CKP_count}_#{group_field_id}".to_sym)
        unless c
          c = self.count(:conditions => self::Count_Cache_Group_Field ? ["#{self::Count_Cache_Group_Field} = ?", group_field_id] : [])

          Cache.set("#{self::CKP_count}_#{group_field_id}".to_sym, c, Cache_TTL)
        end
        c
      end

      def including_model.increase_count_cache(group_field_id, count = 1)
        c = Cache.get("#{self::CKP_count}_#{group_field_id}".to_sym)
        if c
          updated_c = c.to_i + count

          Cache.set("#{self::CKP_count}_#{group_field_id}".to_sym, updated_c, Cache_TTL)
        end
      end

      def including_model.decrease_count_cache(group_field_id, count = 1)
        c = Cache.get("#{self::CKP_count}_#{group_field_id}".to_sym)
        if c
          updated_c = c.to_i - count

          Cache.set("#{self::CKP_count}_#{group_field_id}".to_sym, updated_c, Cache_TTL)
        end
      end

      def including_model.clear_count_cache(group_field_id)
        Cache.delete("#{self::CKP_count}_#{group_field_id}".to_sym)
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
          self::Belongs_To_Keys.each_index do |i|
            init[self::Belongs_To_Keys[i]] = belongs_to_ids[i]
          end
          
          record = self.new(init)
        end
        
        record
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
        
        self.search(
          :group_by => options[:group_by] || "updated_at",
          :group_function => options[:group_function] || :day,
          :group_clause => options[:group_clause] || "@group ASC",
          # :match_mode => self::Search_Match_Mode,
          # :order => "updated_at ASC",
          :with => {
            :school_id => school_id,
            :updated_at => from_time..to_time
          }.merge(options[:with] || {})
        ).inject({}) do |hash, record|
          hash[record.sphinx_attributes["@groupby"].to_s] = record.sphinx_attributes["@count"]
          hash
        end
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

end
