var DIALOG_INIT_WIDTH = 500;
var DIALOG_INIT_HEIGHT = "auto";


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
					
					set_dialog_title(type_name + " : " + part_id);
					set_dialog_content(type_name + " : " + part_id);
					open_dialog(this);
				}
			).css(
				{
					cursor: "pointer"
				}
			);
		}
	);
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
			position: calculate_dialog_position(),
			
			modal: false,
			
			close: function() {
				hide_highlighter(1);
			}
		}
	);
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


function set_dialog_title(title) {
	$("#dialog").dialog("option", "title", title);
}


function set_dialog_content(content) {
	$("#dialog").html(content);
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
