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
          Utils.lines(change.insert).map { |line|
            %Q{<ins class="differ">#{line}</ins>}
          }.join(newline)
        end

        def as_delete(change)
          Utils.lines(change.delete).map { |line|
            %Q{<del class="differ">#{line}</del>}
          }.join(newline)
        end

        def as_change(change)
          as_delete(change) << newline << as_insert(change)
        end
        
        def newline
          "\n"
        end
      end
    end
  end
end