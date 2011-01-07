class InternLogsJobIndex < ActiveRecord::Migration
  def self.up
    
    add_index :intern_logs, [:job_id, :event_id, :result_id, :occur_at],
              :name => :index_intern_logs_on_job_and_event_and_result_and_occur
    
  end

  def self.down
    
    remove_index :intern_logs, :name => :index_intern_logs_on_job_and_event_and_result_and_occur
    
  end
end
