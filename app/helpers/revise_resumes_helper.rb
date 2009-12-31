module ReviseResumesHelper

  def diff_content_list(target, source)
    # Differ.diff_by_line(target, source).format_as(Differ::Format::HTMLList)
		
		Differ.diff_by_char(
		  compact_newline(target),
		  compact_newline(source)
		).format_as(Differ::Format::HTMLList)
  end
  
  
  def compact_newline(text)
    text.gsub(/\r\n?/, "\n").gsub(/\n+/, "\n")
  end
  
end
