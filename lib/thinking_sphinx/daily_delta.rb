class DailyDelta < ThinkingSphinx::Deltas::DefaultDelta
  
  attr_accessor :column, :hour, :minute
  
  def initialize(index, options)
    @index      = index
    @column     = options[:column] || :updated_at
    @hour       = options[:hour]
    @minute     = options[:minute] || 0
    @rate       = options[:rate]
    @batch       = options[:batch] || 100
    
    raise "Must set :hour" if @hour.blank?
  end
  
  def index(model, instance = nil)
    # do nothing
    true
  end
  
  def delayed_index(model)
    config = ThinkingSphinx::Configuration.instance
    client = Riddle::Client.new config.address, config.port
    rotate = ThinkingSphinx.sphinx_running? ? "--rotate" : ""
    
    output = `#{config.bin_path}#{config.indexer_binary_name} --config #{config.config_file} #{rotate} #{delta_index_name(model)}`
    puts output unless ThinkingSphinx.suppress_delta_output?
    
    # remove the docs that are in both core and delta index
    # the parameter *rate* can be used to reduce the amount of data
    # if a *rate* is specified, only find out the data from last time delta index
    if ThinkingSphinx.sphinx_running?
      index_name = core_index_name(model)
      model.find(
        :all,
        :conditions => ["#{model.connection.quote_column_name(@column.to_s)} > ?", last_index_at]
      ).in_groups_of(@batch, false) do |group|
        changes = {}
        group.each do |instance|
          changes[instance.sphinx_document_id] = [1]
        end
        
        client.update(index_name, ["sphinx_deleted"], changes)
      end
    end
    
    true
  end
        
  def toggle(instance)
    # do nothing
  end
  
  def toggled(instance)
    instance.send(@column) > last_overall_index_at
  end
  
  def reset_query(model)
    nil
  end
  
  def clause(model, toggled)
    if toggled
      "#{model.quoted_table_name}.#{model.connection.quote_column_name(@column.to_s)}" +
      " > '#{last_overall_index_at.to_s(:db)}'"
    else
      nil
    end
  end
  
  
  
  def last_overall_index_at
    now = Time.now
    date = Time.local(now.year, now.month, now.mday, @hour, @minute)
    
    (now < date) ? 1.day.ago(date) : date
  end
  
  def last_index_at
    (@rate && @rate.ago) || last_overall_index_at
  end
  
end
