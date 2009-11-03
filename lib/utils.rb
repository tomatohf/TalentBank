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

end
