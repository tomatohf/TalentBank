module CareerCommunity
  
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


  module Util
    
    def self.included(klass)
      def klass.expand_cache_key(key)
        ActiveSupport::Cache.expand_cache_key(key, :views)
      end
    end
    
    def deep_copy(ar)
      Marshal::load(Marshal.dump(ar))
    end
    
    def truncate_text(text, len, append = "...")
      return "" if text.nil?
      text.mb_chars.length > len ? text.mb_chars[0...(len - append.mb_chars.length)] + append : text
    end
    
    def get_unique_id
      now = Time.now
      "#{now.to_i}_#{now.usec}_#{Process.pid}"
    end
    
  end

end
