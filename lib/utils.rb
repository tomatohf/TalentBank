module Utils
  
  # !!! the method to generate initial password
  def self.generate_password(uid = "")
    "pass#{uid}word"
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
      
      def including_model.get_record(belongs_to_id)
        record = self.find(:first, :conditions => ["#{self::Belongs_To_Key} = ?", belongs_to_id])
        record || self.new(self::Belongs_To_Key => belongs_to_id)
      end
      
    end
  end

end
