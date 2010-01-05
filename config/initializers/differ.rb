require "differ"

module Differ
  module Format
    module HTMLList
      class << self
        def format(change)
          (change.change? && as_change(change)) ||
          (change.delete? && as_delete(change)) ||
          (change.insert? && as_insert(change)) ||
          ''
        end

      private
        def as_insert(change)
          list(change.insert).map { |line|
            %Q{<ins class="differ">#{line}</ins>}
          }.join(newline)
        end

        def as_delete(change)
          list(change.delete).map { |line|
            %Q{<del class="differ">#{line}</del>}
          }.join(newline)
        end

        def as_change(change)
          as_delete(change) << as_insert(change)
        end
        
        def newline
          "\n"
        end
        
        def list(change)
          lines = Utils.lines(change, false)
          lines << "" if change[-1, 1] == newline
          lines
        end
      end
    end
  end
end