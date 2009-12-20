function setup_resume_parts() {
	$.each(
		RESUME_TYPES,
		function(i, type) {
			var type_name = type.name;
			
			$("[id^='" + type_name + "_']").unbind("mouseenter mouseleave").hover(
				function() {
					var padding_x = 5;
					var padding_y = 1;
					
					$("#highlighter")
						.css(
							{
								left: $(".resume").position().left + padding_x,
								top: $(this).position().top - padding_y,
								"z-index": -1
							}
						)
						.height($(this).height() + (padding_y*2))
						.width($(".resume").width() - (padding_x*2))
						.fadeIn("fast");
				},
				function() {
					$("#highlighter").hide();
				}
			).unbind("click").click(
				function() {
					var part_id = $(this).attr("id").substr(type_name.length + 1);
					
					alert(type_name + ": " + part_id);
				}
			).css(
				{
					cursor: "pointer"
				}
			);
		}
	);
}


$(document).ready(
	function() {
		setup_resume_parts();
	}
);
