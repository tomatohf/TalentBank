var DIALOG_INIT_WIDTH = 500;
var DIALOG_INIT_HEIGHT = 350;

var BTN_PADDING_BIG = "0.4em 1em 0.5em";
var BTN_PADDING_SMALL = "0.2em 0.6em 0.3em";


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
					var section_title = get_section_title(this);
					if(section_title) {
						set_dialog_title(section_title, get_dialog_sub_title(type_name, this));

						prepare_dialog_content(type, this);

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


function get_section_title(part) {
	var section = ancestor_with_class(part, "resume_section");
	
	return section && $.trim(section.prev(".resume_section_title").html());
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
	sub_title = $.trim(sub_title);
	if(sub_title != "") {
		title += " - " + sub_title;
	}
	$("#dialog").dialog("option", "title", title);
}


function get_dialog_sub_title(type_name, part) {
	var sub_title = "";
	if(type_name == "edu") {
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


function beautify_buttons(buttons, padding) {
	return buttons.css(
		{
			cursor: "pointer",
			padding: padding,
			marginLeft: "10px"
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
}


function setup_dialog_buttons(type, part) {
	$("#new_revision_actions").html(
		'建议:' +
		'<button id="action_update">修改内容</button>' +
		'<button id="action_destroy">删除这段</button>' +
		'<button id="action_add">添加内容</button>'
	);
	
	beautify_buttons(
		$("#new_revision_actions button"),
		BTN_PADDING_BIG
	).unbind("click").click(
		function() {
			var action = $(this).attr("id").substr("action_".length);
			
			var btn_label = $(this).html();
			var btn_left = $(this).position().left
							- parseFloat($(this).parent().parent().css("paddingLeft"))
							- parseFloat($("#dialog").css("paddingLeft"))
							+ parseFloat($(this).css("marginLeft"));
			
			$("#new_revision_actions")
				.html('<button>' + btn_label + '</button>')
				.find("button")
					.addClass("ui-state-active ui-corner-all")
					.css(
						{
							padding: BTN_PADDING_BIG,
							position: "relative",
							left: btn_left
						}
					)
					.animate(
						{
							left: 0
						}
					);
			
			draw_new_revision_form(action, type, part);
		}
	);
}


function draw_new_revision_form(action, type, part) {
	var form_container = '<div></div>';
	
	var type_id_input = '<input type="hidden" id="type_id" />';
	var part_id_input = '<input type="hidden" id="part_id" />';
	var part_id = $(part).attr("id").substr(type.name.length + 1);
	
	form_container = $(form_container).css(
		{
			padding: "20px 30px 10px 20px",
			display: "none"
		}
	)
	.append($(type_id_input).val(type.id))
	.append($(part_id_input).val(part_id));
	
	if(action == "destroy") {
		
	}
	else {
		form_container.append(get_new_revision_inputs(type, part, action == "update"));
	}
	
	$("#new_revision_form").html(form_container);
	form_container.fadeIn("slow").find(".text_field:first").focus();
}


function get_new_revision_inputs(type, part, modify) {
	var inputs_container = $('<div></div>');
	
	var type_name = type.name;
	if(type_name == "edu") {
		
	}
	else if(type_name.indexOf("_exp") >= 0) {
		
	}
	else if(type_name.indexOf("_skill") >= 0) {
		
	}
	else if(
		type_name == "job_intention" ||
		type_name == "award" || type_name == "hobby" ||
		type_name == "list_section"
	) {
		if(type_name == "job_intention") {
			var input = '<input type="text" id="job_intention_content" />';
			input = $(input).addClass("text_field ui-corner-all").css(
				{
					width: "100%"
				}
			).val(modify ? $.trim($(part).html()) : "");
			$('<div></div>').append(input).appendTo(inputs_container);
		}
		else {
			if(type_name == "list_section") {
				var input = '<input type="text" id="list_section_title" />';
				input = $(input).addClass("text_field ui-corner-all").css(
					{
						width: "75%",
						margin: "0px 0px 10px 16px"
					}
				).val(modify ? get_section_title(part) : "");
				$('<div>标题:</div>').append(input).appendTo(inputs_container);
			}
			
			var textarea = '<textarea rows="5"></textarea>';
			textarea = $(textarea)
				.attr("id", type_name + "_content")
				.addClass("text_field ui-corner-all")
				.css(
					{
						width: "100%"
					}
				).val(modify ? items_to_text($(part).find("ul")) : "");
			$('<div></div>').append(textarea).appendTo(inputs_container);
		}
	}
	
	var submit_button = '<button>提交内容</button>';
	submit_button = beautify_buttons(
		$(submit_button),
		BTN_PADDING_SMALL
	).unbind("click").click(
		function() {
			alert("submit");
		}
	)
	var reset_link = '<a href="#">取消</a>';
	reset_link = $(reset_link).addClass("none").css(
		{
			marginLeft: "20px"
		}
	).unbind("click").click(
		function() {
			prepare_dialog_content(type, part);
			
			return false;
		}
	);
	$('<div style="margin-top: 15px;"></div>').append(submit_button).append(reset_link).appendTo(inputs_container);
	
	return inputs_container;
}


function items_to_text(ul) {
	return $.map(
		$(ul).find("li"),
		function(li, i) {
			return $(li).html();
		}
	).join("\n");
}


function prepare_dialog_content(type, part) {
	setup_dialog_buttons(type, part);
	$("#new_revision_form").html("");
}


$(document).ready(
	function() {
		setup_tabs();
		
		setup_resume_parts();
		
		setup_dialog();
	}
);
