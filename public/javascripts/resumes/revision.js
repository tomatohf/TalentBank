var DIALOG_INIT_WIDTH = 500;
var DIALOG_INIT_HEIGHT = 350;


function setup_tabs() {
	$(".tabs").css(
		{
			border: "none",
			background: "transparent"
		}
	).tabs().show();
}


function setup_resume_parts() {
	$.each(
		RESUME_TYPES,
		function(i, type) {
			var type_name = type.name;
			
			$("[id^='" + type_name + "_']").unbind("mouseenter mouseleave").hover(
				function() {
					show_highlighter(2, this);
				},
				function() {
					hide_highlighter(2);
				}
			).unbind("click").click(
				function() {
					var part_id = $(this).attr("id").substr(type_name.length + 1);
					
					var section = ancestor_with_class(this, "resume_section");
					if(section != null) {
						var sub_title = "";
						if(type_name.indexOf("edu") >= 0) {
							var edu_info = [];
							$.each(
								$(this).find("td"),
								function(i, td) {
									var td_html = $.trim($(td).html());
									if(td_html != "") {
										edu_info.push(td_html);
									}
								}
							)
							sub_title = edu_info.join(" / ");
						}
						else if(type_name.indexOf("_exp") >= 0) {
							sub_title = $.trim($(this).find("td div.resume_exp_title").html()) +
										" (" + $.trim($(this).find("td.resume_exp_period").html()) + ")";
						}
						else if(type_name.indexOf("_skill") >= 0) {
							sub_title = $(this).find("td:first").html();
						}
						set_dialog_title(section.prev(".resume_section_title").html(), sub_title);

						open_dialog(this);
					}
				}
			).css(
				{
					cursor: "pointer"
				}
			);
		}
	);
}


function ancestor_with_class(part, class_name) {
	var element = $(part);
	while(!element.hasClass(class_name)) {
		element = element.parent();
		
		if(element.length <= 0) {
			return null;
		}
	}
	
	return element;
}


function show_highlighter(index, part) {
	var padding_x = 5;
	var padding_y = 1;
	
	$("#highlighter_" + index)
		.css(
			{
				left: $(".resume").position().left + padding_x,
				top: $(part).position().top - padding_y,
				"z-index": (0-index)
			}
		)
		.height($(part).height() + (padding_y*2))
		.width($(".resume").width() - (padding_x*2))
		.fadeIn("fast");
}


function hide_highlighter(index) {
	$("#highlighter_" + index).hide();
}


function setup_dialog() {
	$("#dialog").dialog(
		{
			autoOpen: false,
			closeOnEscape: true,
			
			title: "",
			
			draggable: true,
			resizable: true,
			
			show: "fade",
			hide: "fade",
			
			width: DIALOG_INIT_WIDTH,
			height: DIALOG_INIT_HEIGHT,
			maxWidth: 950,
			maxHeight: 600,
			minWidth: 400,
			position: calculate_dialog_position(),
			
			modal: false,
			
			close: function() {
				hide_highlighter(1);
			}
		}
	).show();
}


function calculate_dialog_position() {
	var width = $("#dialog").dialog("option", "width") || DIALOG_INIT_WIDTH;
	var left = "center";
	var resume_width = $(".resume").width();
	if(resume_width > width) {
		left = $(".resume").position().left + ((resume_width-width)/2)
	}
	return [left, "center"];
}


function set_dialog_title(title, sub_title) {
	var dialog_title = $.trim(title);
	sub_title = $.trim(sub_title);
	if(sub_title != "") {
		dialog_title += " - " + sub_title;
	}
	$("#dialog").dialog("option", "title", dialog_title);
}


function open_dialog(part) {
	// $("#dialog").dialog("close");
	
	show_highlighter(1, part);
	
	if($("#dialog").dialog("isOpen")) {
		var padding = 20;
		var top = $("#dialog").parent().position().top;
		var height = $("#dialog").parent().height();
		
		if(top < $(document).scrollTop()) {
			top = $(document).scrollTop() + padding;
		}
		
		if(top + height > $(document).scrollTop() + $(window).height()) {
			top = $(document).scrollTop() + $(window).height() - padding - height;
		}
		
		$("#dialog").parent().animate(
			{
				top: top
			}
		);
	}
	else {
		$("#dialog").dialog("option", "position", calculate_dialog_position());
		$("#dialog").dialog("open");
	}
}


$(document).ready(
	function() {
		setup_tabs();
		
		setup_resume_parts();
		
		setup_dialog();
	}
);
