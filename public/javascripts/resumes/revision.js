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
						set_dialog_title(
							section.prev(".resume_section_title").html(),
							get_dialog_sub_title(type_name, this)
						);
						
						prepare_dialog_content(type.id, part_id);

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


function get_dialog_sub_title(type_name, part) {
	var sub_title = "";
	if(type_name.indexOf("edu") >= 0) {
		var edu_info = [];
		$.each(
			$(part).find("td"),
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
		sub_title = $.trim($(part).find("td div.resume_exp_title").html()) +
					" (" + $.trim($(part).find("td.resume_exp_period").html()) + ")";
	}
	else if(type_name.indexOf("_skill") >= 0) {
		sub_title = $(part).find("td:first").html();
	}
	
	return sub_title;
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


function setup_dialog_buttons() {
	var btn_padding = "0.4em 1em 0.5em";
	
	$("#new_revision_actions").html(
		'建议:' +
		'<button id="action_update">修改内容</button>' +
		'<button id="action_destroy">删除这段</button>' +
		'<button id="action_add">添加内容</button>'
	);
	
	$("#new_revision_actions button").css(
		{
			cursor: "pointer",
			padding: btn_padding,
			margin: "0px 0px 0px 10px"
		}
	)
	.addClass("ui-state-default ui-corner-all")
	.unbind("mouseenter mouseleave").hover(
		function() {
			$(this).addClass("ui-state-hover");
		},
		function() {
			$(this).removeClass("ui-state-hover");
		}
	)
	.unbind("click").click(
		function() {
			$(this).addClass("ui-state-active");
			
			var revision_action = $(this).attr("id").substr("action_".length);
			var btn_label = $(this).html();
			var btn_left = $(this).position().left;
			
			$.get(
				"/teachers/" + TEACHER_ID + "/revise_resumes/" + RESUME_ID + "/revisions/new",
				{
					revision_action: revision_action
				},
				function(data) {
					$("#new_revision_actions")
						.html('<button>' + btn_label + '</button>')
						.find("button")
							.addClass("ui-state-active ui-corner-all")
							.css(
								{
									padding: btn_padding,
									position: "relative",
									left: btn_left
								}
							)
							.animate(
								{
									left: 0
								}
							);
					
					$("#new_revision_form").html(data);
				},
				"html"
			);
		}
	);
}


function prepare_dialog_content(type_id, part_id) {
	setup_dialog_buttons();
	
	$("#new_revision_form").html("");
}


$(document).ready(
	function() {
		setup_tabs();
		
		setup_resume_parts();
		
		setup_dialog();
	}
);
