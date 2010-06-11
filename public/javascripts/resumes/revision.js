var LINK_COLOR = "#3B5998";

var DIALOG_INIT_WIDTH = 500;
var DIALOG_INIT_HEIGHT = 420;

var BTN_PADDING_BIG = "6px 10px 5px";
var BTN_PADDING_SMALL = "3px 6px 2px";

var UNAPPLIED_PART_DELETED_REVISIONS = [];

var DIALOG_DEFAULT_OPTIONS = {
	autoOpen: false,
	closeOnEscape: true,
	
	title: "",
	
	draggable: true,
	resizable: true,
	
	show: null,
	hide: null,
	
	width: DIALOG_INIT_WIDTH,
	height: DIALOG_INIT_HEIGHT,
	maxWidth: 950,
	maxHeight: 600,
	minWidth: 460,
	
	modal: false
};


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
			
			if(type_name == "exp_section") { return; }
			
			$.each(
				$("[id^='" + type_name + "_']"),
				function(i, part) {
					setup_resume_part(type_name, part);
				}
			);
		}
	);
	
	
	var overall_comment_count = $("#all_comments ._").length;
	var class_name = "resume_overall_comment_pop";
	var pop_container = $(".resume:first");
	pop_container.find("." + class_name).remove();
	var pop = pop_container.prepend(
		$('<span></span>')
			.attr("id", compute_id_for_pop("overall", "comment"))
			.addClass(class_name).html(overall_comment_count)
	).find("." + class_name + ":first").unbind("click").click(overall_comment_pop_click_handler);
	if(overall_comment_count <= 0) {
		pop.hide();
	}
}


function overall_comment_pop_click_handler() {
	fill_overall_comments($("#all_comments ._"), true);
	
	open_overall_comment_dialog();
}


function setup_resume_part(type_name, part) {
	var type = get_type_from_name(type_name);
	
	var part_attr_id = $(part).unbind("mouseenter mouseleave").hover(
		function() {
			show_highlighter(2, this);
		},
		function() {
			hide_highlighter(2);
		}
	).unbind("click").click(
		function(event) {
			$("#dialog").dialog("option", "title", get_dialog_title(this, type_name));
			prepare_dialog_content(type, this);

			open_dialog(this);
			
			
			// switch tab
			if($(event.target).hasClass("resume_revision_pop")) {
				$("#dialog .tabs").tabs("select", "#part_revisions");
			}
			if($(event.target).hasClass("resume_comment_pop")) {
				$("#dialog .tabs").tabs("select", "#part_comments");
			}
		}
	).css(
		{
			cursor: "pointer"
		}
	)
	.attr("id");
	
	
	var revision_count = $("#all_revisions ." + unapplied_class_name() + "." + part_attr_id).length;
	var comment_count = $("#all_comments ." + part_attr_id).length;
	$.each(
		[
			["revision", revision_count],
			["comment", comment_count]
		],
		function(i, info) {
			var count = info[1];
			var key = info[0];
			
			var class_name = "resume_" + key + "_pop";
			
			var pop_container = $(part);
			var pop_container_tagname = pop_container.attr("tagName").toLowerCase();
			if(pop_container_tagname == "tr") {
				pop_container = pop_container.find("td:first");
			}
			else if(pop_container_tagname == "table") {
				pop_container = pop_container.find("tr:first > td:first");
			}
			
			pop_container.find("." + class_name).remove();
			var pop = pop_container.prepend(
				$('<span></span>')
					.attr("id", compute_id_for_pop(part_attr_id, key))
					.addClass(class_name).html(count)
			).find("." + class_name + ":first");
			
			if(count <= 0) {
				pop.hide();
			}
			
			if(key == "comment") {
				pop.css("marginLeft", $(part).width() + "px");
			}
			
			
			if(is_ie6()) {
				pop.css("backgroundImage", "url(/images/revise_resumes/" + key + "_pop.gif)");
			}
		}
	);
}


function get_section_title(part) {
	var section = ancestor_with_class(part, "resume_section");
	
	var title = "";
	if(section) {
		var section_title = section.prev(".resume_section_title");
		if(section_title) {
			var copied_section_title = section_title.clone();
			copied_section_title.find("").remove();
			copied_section_title.find(".resume_revision_pop").add(
				copied_section_title.find(".resume_comment_pop")
			).remove();
			title = $.trim(copied_section_title.html());
		}
	}
	return title;
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


function get_type_from_name(name) {
	var type = null
	
	$.each(
		RESUME_TYPES,
		function(i, resume_type) {
			if(resume_type.name == name) {
				type = resume_type;
			}
		}
	);
	
	return type;
}


function show_highlighter(index, part) {
	var padding_x = 5;
	var padding_y = 1;
	
	var width = $(".resume").width() - (padding_x*2);
	var height = $(part).height();
	var left = $(".resume").position().left + padding_x;
	var top = $(part).position().top - padding_y + to_number($(part).css("marginTop"));
	if($(part).attr("id").indexOf("job_intention") >= 0) {
		width = $(part).outerWidth() - (padding_x*2);
	}
	if($(part).attr("id").indexOf("exp_section_title") >= 0) {
		var shift_x = padding_x;
		var shift_y = 4;
		width += shift_x*2;
		height += shift_y*2;
		left -= shift_x;
		top -= shift_y;
	}
	
	$("#highlighter_" + index)
		.css(
			{
				left: left,
				top: top,
				"z-index": (0-index)
			}
		)
		.height(height + (padding_y*2))
		.width(width)
		.fadeIn("fast");
}


function hide_highlighter(index) {
	$("#highlighter_" + index).hide();
}


function setup_dialog() {
	$("#dialog").dialog(
		$.extend(
			{},
			DIALOG_DEFAULT_OPTIONS,
			{
				position: calculate_dialog_position("#dialog"),
				
				close: function() {
					hide_highlighter(1);
				},

				resize: function(event, ui) {
					adjust_tabs_content_height_by_dialog("#dialog");
				},
				open: function(event, ui) {
					$("#overall_comment_dialog").dialog("close");
					adjust_tabs_content_height_by_dialog("#dialog");
				}
			}
		)
	).show();
	
	
	// make dialog title NOT wrap, and hide too long text
	$("span#ui-dialog-title-dialog").css(
		{
			width: "95%",
			overflow: "hidden",
			whiteSpace: "nowrap"
		}
	);
}


function setup_overall_comment_dialog() {
	$("#overall_comment_dialog").dialog(
		$.extend(
			{},
			DIALOG_DEFAULT_OPTIONS,
			{
				title: "整份简历的评注",
				
				position: calculate_dialog_position("#overall_comment_dialog"),
				
				resize: function(event, ui) {
					adjust_tabs_content_height_by_dialog("#overall_comment_dialog");
				},
				open: function(event, ui) {
					$("#dialog").dialog("close");
					adjust_tabs_content_height_by_dialog("#overall_comment_dialog");
				}
			}
		)
	).show();
}


function adjust_tabs_content_height_by_dialog(dialog) {
	$.each(
		$(dialog).css("overflow", "hidden").find(".tabs > div"),
		function(i, div) {
			var dialog_h = $(dialog).innerHeight();
			var tabs_nav_h = $(dialog).find(".tabs ul:first").outerHeight(true);
			var div_margin = to_number($(div).css("marginTop")) + to_number($(div).css("marginBottom"));
			var div_padding = to_number($(div).css("paddingTop")) + to_number($(div).css("paddingBottom"));
			var fix_h = 20;
			
			var div_h = dialog_h - tabs_nav_h - div_margin - div_padding - fix_h;
			
			$(div).height(div_h)
				.css("overflow", "auto")
				.css("overflow-x", "hidden");
			
			
			if(is_ie6()) {
				$(div).width($(dialog).find(".tabs").width() - 35);
			}
		}
	);
}


function to_number(value) {
	var number = parseFloat(value);
	return isNaN(number) ? 0 : number;
}


function calculate_dialog_position(dialog) {
	var width = $(dialog).dialog("option", "width") || DIALOG_INIT_WIDTH;
	var left = "center";
	var resume_width = $(".resume:first").width();
	if(resume_width > width) {
		left = $(".resume").position().left + ((resume_width-width)/2)
	}
	return [left, "center"];
}


function get_dialog_title(part, type_name) {
	var title = (type_name == "exp_section_title") ? "经历块标题" : get_section_title(part);
	
	var sub_title = get_dialog_sub_title(type_name, part);
	if(sub_title != "") {
		title += " - " + sub_title;
	}
	
	return title;
}


function get_dialog_sub_title(type_name, part) {
	part = $(part).clone();
	$(part).find(".resume_revision_pop").add($(part).find(".resume_comment_pop")).remove();
	
	
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
	else if(type_name == "exp_section_title") {
		sub_title = $(part).html();
	}
	
	return $.trim(sub_title);
}


function open_dialog(part) {
	$("#overall_comment_dialog").dialog("close");
	
	show_highlighter(1, part);
	
	var dialog_height = $("#dialog").dialog("option", "height");
	var part_top = $(part).position().top;
	var part_height = $(part).height();
	var document_scroll = $(document).scrollTop();
	
	var spacing = 20;
	var padding = ($(window).height() - part_height - spacing - dialog_height) / 2;
	if(padding < 5) { padding = 5; }
	
	var part_align_top = true;
 	document_scroll = part_top - padding;
	if(part_top + (part_height / 2) > $(document).height() / 2) {
		part_align_top = false;
		document_scroll = part_top + part_height + padding - $(window).height();
	}
	
	$("html, body").animate(
		{
			scrollTop: document_scroll
		},
		function() {
			if(!$("#dialog").dialog("isOpen")) {
				$("#dialog").dialog("option", "position", calculate_dialog_position("#dialog"));
				$("#dialog").dialog("open");
			}
			
			var dialog_y = part_top - spacing - dialog_height;
			if(part_align_top) {
				dialog_y = part_top + part_height + spacing;
			}

			$("#dialog").parent().animate(
				{
					top: dialog_y
				}
			);
		}
	);
}


function open_overall_comment_dialog() {
	$("#dialog").dialog("close");
	
	if(!$("#overall_comment_dialog").dialog("isOpen")) {
		$("#overall_comment_dialog").dialog("close");
	}
	
	$("#overall_comment_dialog").dialog("option", "position", calculate_dialog_position("#overall_comment_dialog"));
	$("#overall_comment_dialog").dialog("open");
}


function beautify_buttons(buttons, padding) {
	return buttons.css(
		{
			cursor: "pointer",
			padding: padding,
			marginLeft: "15px"
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


function get_action_icon(action) {
	var icon = null;
	
	if(action == "update") {
		icon = "ui-icon-pencil";
	}
	else if(action == "delete") {
		icon = "ui-icon-trash";
	}
	else if(action == "add") {
		icon = "ui-icon-circle-plus";
	}
	
	return icon ? '<span class="ui-icon ' + icon + ' float_l"></span>' : '';
}


function setup_new_revision_buttons(type, part) {
	var type_name = type.name;
	var buttons_html = '建议:';
	if(type_name != "student_skill") {
		buttons_html += '<button id="action_update">' + get_action_icon("update") + '修改内容</button>';
	}
	if(type_name != "exp_section_title") {
		buttons_html += '<button id="action_delete">' + get_action_icon("delete") + '删除这段</button>';
		if(type_name != "job_intention" && type_name != "award" && type_name != "hobby") {
			buttons_html += '<button id="action_add">' + get_action_icon("add") + '添加内容</button>';
		}
	}
	$("#new_revision_actions").html(buttons_html);
	
	
	$.each(
		$("#new_revision_actions").find("button"),
		function(i, button) {
			$(button).css("width", "100px");
		}
	);
	
	
	beautify_buttons(
		$("#new_revision_actions button"),
		BTN_PADDING_BIG
	).unbind("click").click(
		function() {
			var action = $(this).attr("id").substr("action_".length);
			
			var btn_label = $(this).html();
			var btn_left = $(this).position().left
							- to_number($(this).parent().parent().css("paddingLeft"))
							- to_number($("#dialog").css("paddingLeft"))
							+ to_number($(this).css("marginLeft"));
			var btn_width = $(this).css("width");
			
			$("#new_revision_actions")
				.html('<button>' + btn_label + '</button>')
				.find("button")
					.addClass("ui-state-active ui-corner-all")
					.css(
						{
							padding: BTN_PADDING_BIG,
							position: "relative",
							left: btn_left,
							width: btn_width
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
	
	var type_id_input = '<input type="hidden" name="revision_type_id" />';
	var part_id_input = '<input type="hidden" name="revision_part_id" />';
	var revision_action_input = '<input type="hidden" name="revision_action" />';
	var part_id = $(part).attr("id").substr(type.name.length + 1);
	
	form_container = $(form_container).css(
		{
			padding: "20px 30px 0px 20px",
			display: "none"
		}
	)
	.append($(type_id_input).val(type.id))
	.append($(part_id_input).val(part_id))
	.append($(revision_action_input).val(action));
	
	if(action == "delete") {
		form_container.append('<div>确定要添加删除这段的建议么?</div>');
		
		add_submit_button(
			form_container,
			function() {
				create_revision(type, part);
			},
			function() {
				prepare_new_revision_content(type, part);
				
				return false;
			}
		);
	}
	else {
		form_container.append(get_new_revision_inputs(type, part, action == "update"));
	}
	
	$("#new_revision_form").html(form_container);
	form_container.fadeIn("slow").find(".text_field:first").focus();
}


function get_new_revision_inputs(type, part, modify) {
	var original_part = part;
	part = $(original_part).clone();
	$(part).find(".resume_revision_pop").add($(part).find(".resume_comment_pop")).remove();
	
	
	var inputs_container = $('<div></div>');
	
	var type_name = type.name;
	if(type_name == "edu") {
		table_for_text_fields(
			[
				["edu_period", "时间段" + required_mark],
				["edu_university", "大学"],
				["edu_college", "学院"],
				["edu_major", "专业"],
				["edu_type", "教育类型"]
			],
			part,
			modify
		).appendTo(inputs_container);
	}
	else if(type_name.indexOf("_exp") >= 0) {
		$('<table border="0" cellspacing="0" cellpadding="5"></table>')
			.addClass("main_part_w")
			.append(
				table_row_for_text_field(
					"exp_period",
					"时间段" + required_mark,
					modify ? $.trim($(part).find(".resume_exp_period").html()) : "",
					false
				)
			)
			.append(
				table_row_for_text_field(
					"exp_title",
					"标题" + required_mark,
					modify ? $.trim($(part).find(".resume_exp_title").html()) : "",
					false
				)
			)
			.append(
				table_row_for_text_field(
					"exp_sub_title",
					"子标题",
					modify ? $.trim($(part).find(".resume_exp_sub_title").html()) : "",
					false
				)
			)
			.append(
				table_row_for_text_field(
					"exp_content",
					"内容" + required_mark,
					modify ? items_to_text($(part).find("ul")) : "",
					true
				)
			)
			.appendTo(inputs_container);
	}
	else if(type_name.indexOf("_skill") >= 0) {
		table_for_text_fields(
			[
				["skill_name", "名称" + required_mark],
				["skill_level", "程度"]
			],
			part,
			modify
		).appendTo(inputs_container);
	}
	else if(type_name == "list_section") {
		$('<table border="0" cellspacing="0" cellpadding="5"></table>')
			.addClass("main_part_w")
			.append(
				table_row_for_text_field(
					"section_title",
					"标题" + required_mark,
					modify ? get_section_title(original_part) : "",
					false
				)
			)
			.append(
				table_row_for_text_field(
					"section_content",
					"内容" + required_mark,
					modify ? items_to_text($(part).find("ul")) : "",
					true
				)
			)
			.appendTo(inputs_container);
	}
	else if(
		type_name == "job_intention" || type_name == "exp_section_title" ||
		type_name == "award" || type_name == "hobby"
	) {
		var multi_line = !(type_name == "job_intention" || type_name == "exp_section_title");
		div_for_text_field(
			type_name,
			modify ? (multi_line ? items_to_text($(part).find("ul")) : $.trim($(part).html())) : "",
			multi_line
		).appendTo(inputs_container);
	}
	
	add_submit_button(
		inputs_container,
		function() {
			create_revision(type, original_part);
		},
		function() {
			prepare_new_revision_content(type, original_part);
			
			return false;
		}
	);
	
	return inputs_container;
}


function get_edit_revision_form(revision) {
	var form_container = $('<div></div>');
	
	var revision_data = $(revision).find(".resume_revision_data:first").find("div:first");
	
	var target_part_id = $(revision).find("input:hidden:first").val();
	var type_name = target_part_id.substring(0, target_part_id.lastIndexOf("_"));
	if(type_name == "edu") {
		table_for_text_fields(
			[
				["edu_period", "时间段" + required_mark],
				["edu_university", "大学"],
				["edu_college", "学院"],
				["edu_major", "专业"],
				["edu_type", "教育类型"]
			],
			revision_data,
			true
		).appendTo(form_container);
	}
	else if(type_name.indexOf("_exp") >= 0) {
		$('<table border="0" cellspacing="0" cellpadding="5"></table>')
			.addClass("main_part_w")
			.append(
				table_row_for_text_field(
					"exp_period",
					"时间段" + required_mark,
					$.trim($(revision_data).find("td:first").html()),
					false
				)
			)
			.append(
				table_row_for_text_field(
					"exp_title",
					"标题" + required_mark,
					$.trim($(revision_data).find(".resume_exp_title").html()),
					false
				)
			)
			.append(
				table_row_for_text_field(
					"exp_sub_title",
					"子标题",
					$.trim($(revision_data).find("td:last div.float_r").html()),
					false
				)
			)
			.append(
				table_row_for_text_field(
					"exp_content",
					"内容" + required_mark,
					items_to_text($(revision_data).find("ul")),
					true
				)
			)
			.appendTo(form_container);
	}
	else if(type_name.indexOf("_skill") >= 0) {
		table_for_text_fields(
			[
				["skill_name", "名称" + required_mark],
				["skill_level", "程度"]
			],
			revision_data,
			true
		).appendTo(form_container);
	}
	else if(type_name == "list_section") {
		$('<table border="0" cellspacing="0" cellpadding="5"></table>')
			.addClass("main_part_w")
			.append(
				table_row_for_text_field(
					"section_title",
					"标题" + required_mark,
					$.trim($(revision_data).find("div.resume_section:first div:first").html()),
					false
				)
			)
			.append(
				table_row_for_text_field(
					"section_content",
					"内容" + required_mark,
					items_to_text($(revision_data).find("ul")),
					true
				)
			)
			.appendTo(form_container);
	}
	else if(
		type_name == "job_intention" || type_name == "exp_section_title" ||
		type_name == "award" || type_name == "hobby"
	) {
		var multi_line = !(type_name == "job_intention" || type_name == "exp_section_title");
		div_for_text_field(
			type_name,
			multi_line ? items_to_text($(revision_data).find("ul")) : $.trim($(revision_data).find("div.resume_section:first").html()),
			multi_line
		).appendTo(form_container);
	}
	
	add_submit_button(
		form_container,
		function() {
			update_revision(revision);
		},
		function() {
			$(revision).find(".resume_revision_form").hide();
			$(revision).find(".resume_revision_diff").hide();
			$(revision).find("button.diff_revision_btn").removeClass("ui-state-active");
			$(revision).find(".resume_revision_data").show();
			
			return false;
		}
	);
	
	return form_container;
}


function get_edit_comment_form(comment) {
	var form_container = $('<div></div>');
	
	div_for_text_field(
		"comment",
		$.trim($(comment).find("pre.preformatted_content:first").text()),
		true
	).appendTo(form_container);
	
	add_submit_button(
		form_container,
		function() {
			update_comment(comment);
		},
		function() {
			$(comment).find(".resume_comment_form").hide();
			$(comment).find("pre.preformatted_content").show();
			
			return false;
		}
	);
	
	return form_container;
}


function table_for_text_fields(fields, part, modify) {
	var table = $('<table border="0" cellspacing="0" cellpadding="5"></table>').addClass("main_part_w");
	
	$.each(
		fields,
		function(i, field) {
			table.append(
				table_row_for_text_field(
					field[0],
					field[1],
					modify ? $.trim($(part).find("td:nth-child(" + (i+1) + ")").html()) : "",
					false
				)
			);
		}
	);
	
	return table;
}


function table_row_for_text_field(field_id, field_label, field_value, multi_line) {
	var label_column = $('<td></td>').css("width", "60px").append(
		$('<label></label>').attr("for", field_id).html(field_label)
	);
	
	var input_column = $('<td></td>').append(
		div_for_text_field(field_id, field_value, multi_line)
	);
	
	return $('<tr></tr>').append(label_column).append(input_column);
}


function div_for_text_field(field_id, field_value, multi_line) {
	return $('<div></div>').append(
		$(multi_line ? '<textarea rows="5"></textarea>' : '<input type="text" />')
			.attr("name", field_id)
			.addClass("text_field ui-corner-all")
			.css(
				{
					width: "95%"
				}
			)
			.val(field_value)
	);
}


function add_submit_button(container, submit_func, reset_func) {
	$('<div style="margin-top: 15px;"></div>')
		.append(
			beautify_buttons(
				$('<input type="submit" value="提交" />'),
				BTN_PADDING_SMALL
			).unbind("click").click(submit_func)
		)
		.append(
			$('<a href="#">取消</a>').addClass("none").css(
				{
					margin: "0px 25px"
				}
			).unbind("click").click(reset_func)
		)
		.append(
			$('<span></span>').css("color", "#CD0A0A")
		)
		.appendTo(container);
}


function items_to_text(ul) {
	return $.map(
		$(ul).find("li"),
		function(li, i) {
			return $(li).html();
		}
	).join("\r\n");
}


function prepare_dialog_content(type, part) {
	prepare_new_revision_content(type, part);
	// prepare part revisions content
	fill_part_revisions($("#all_revisions ." + $(part).attr("id")), true);
	
	// prepare new comment content
	var part_id = $(part).attr("id").substr(type.name.length + 1);
	$("input#comment_type_id").val(type.id);
	$("input#comment_part_id").val(part_id);
	// prepare part comment content
	fill_part_comments($("#all_comments ." + $(part).attr("id")), true);
}


function prepare_new_revision_content(type, part) {
	setup_new_revision_buttons(type, part);
	$("#new_revision_form").html("");
}


function fill_part_revisions(revisions, replace) {
	var copied_revisions = $(revisions).clone();
	
	$.each(
		copied_revisions,
		function(i, copied_revision) {
			$(copied_revision).attr(
				"id",
				compute_id_for_part($(copied_revision).attr("id"))
			).find(".target_part_title").remove();
		}
	);
	
	if(replace) {
		$("#part_revisions").html(setup_revisions(copied_revisions));
	}
	else {
		$("#part_revisions").append(setup_revisions(copied_revisions));
	}
	
	return copied_revisions;
}


function fill_part_comments(comments, replace) {
	var copied_comments = $(comments).clone();
	
	$.each(
		copied_comments,
		function(i, copied_comment) {
			$(copied_comment).attr(
				"id",
				compute_id_for_part($(copied_comment).attr("id"))
			).find(".target_part_title").remove();
		}
	);
	
	if(replace) {
		$("#part_comments").html(setup_comments(copied_comments));
	}
	else {
		$("#part_comments").append(setup_comments(copied_comments));
	}
	
	return copied_comments;
}


function fill_overall_comments(comments, replace) {
	var copied_comments = $(comments).clone();
	
	$.each(
		copied_comments,
		function(i, copied_comment) {
			$(copied_comment).attr(
				"id",
				compute_id_for_part($(copied_comment).attr("id"))
			).find(".target_part_title").remove();
		}
	);
	
	if(replace) {
		$("#overall_comments").html(setup_comments(copied_comments));
	}
	else {
		$("#overall_comments").append(setup_comments(copied_comments));
	}
	
	return copied_comments;
}


function compute_id_for_part(id) {
	return id + "_part";
}


function compute_id_for_pop(part_attr_id, key) {
	return part_attr_id + "_" + key + "_pop";
}


function create_revision(type, part) {
	if($("#new_revision_form").find("input[name='revision_action']:first").val() != "delete") {
		if(!check_revision_form($("#new_revision_form"), type.name)) {
			return;
		}
	}
	
	
	disable_submit_button("#new_revision_form");
	$("#new_revision_form").find("input:submit").siblings("span:first").hide();
	
	$.ajax(
		{
			type: "POST",
			url: "/" + ACCOUNT_TYPE + "/" + ACCOUNT_ID + "/revise_resumes/" + RESUME_ID + "/revisions",
			dataType: "html",
			data: collect_form_data($("#new_revision_form").find("input:hidden, input:text, textarea")),
			error: function() {
				show_error_msg(
					enable_submit_button("#new_revision_form")
						.siblings("span:first")
				);
			},
			success: function(data, text_status) {
				// clear form inputs
				prepare_new_revision_content(type, part);
				
				// append revision html
				var revision_attr_id = setup_revisions($(data)).appendTo($("#all_revisions")).attr("id");
				$(part).click();
				
				// switch tab
				$("#dialog .tabs").tabs("select", "#part_revisions");
				
				$("#part_revisions").scrollTop($("#part_revisions")[0].scrollHeight);
				
				// fade in effect
				$("#" + revision_attr_id)
				.add("#" + compute_id_for_part(revision_attr_id))
					.css("opacity", 0).animate({opacity: 1}, "slow");
				
				
				// adjust pop count
				if(is_revision_unapplied($("#" + revision_attr_id))) {
					adjust_revision_pop_count($(part).attr("id"), 1);
				}
			}
		}
	);
}


function update_revision(revision) {
	var target_part_id = $(revision).find("input:hidden:first").val();
	var type_name = target_part_id.substring(0, target_part_id.lastIndexOf("_"));
	var form_container = $(revision).find(".resume_revision_form:first");
	if(!check_revision_form(form_container, type_name)) {
		return;
	}
	
	
	disable_submit_button(form_container);
	$(form_container).find("input:submit").siblings("span:first").hide();
	
	var revision_id = parseInt($(revision).attr("id").substr("revision_".length));
	var form_data = collect_form_data($(form_container).find("input:hidden, input:text, textarea"));
	form_data["_method"] = "put"; // simulate HTTP put request in rails
	$.ajax(
		{
			type: "POST",
			url: "/" + ACCOUNT_TYPE + "/" + ACCOUNT_ID + "/revise_resumes/" + RESUME_ID + "/revisions/" + revision_id,
			dataType: "html",
			data: form_data,
			error: function() {
				show_error_msg(enable_submit_button(form_container).siblings("span:first"));
			},
			success: function(data, text_status) {
				var revision_attr_id = "revision_" + revision_id;
				var update_revisions = $("#" + revision_attr_id).add("#" + compute_id_for_part(revision_attr_id));

				var content_containers = update_revisions.find(".resume_revision_content:first");
				content_containers.html(
					$('<div class="resume_revision_data"></div>').html(data)
				);
			}
		}
	);
}


function update_comment(comment) {
	var form_container = $(comment).find(".resume_comment_form:first");
	var text_field = form_container.find("textarea:first");
	if($.trim(text_field.val()).length > 1000) {
		return fail_msg("内容超过长度限制 ...");
	}
	if($.trim(text_field.val()).length <= 0) {
		return fail_msg("请输入内容 ...");
	}
	
	
	disable_submit_button(form_container);
	$(form_container).find("input:submit").siblings("span:first").hide();
	
	var comment_id = parseInt($(comment).attr("id").substr("comment_".length));
	$.ajax(
		{
			type: "POST",
			url: "/" + ACCOUNT_TYPE + "/" + ACCOUNT_ID + "/revise_resumes/" + RESUME_ID + "/comments/" + comment_id,
			dataType: "html",
			data: {
				content: text_field.val(),
				_method: "put" // simulate HTTP put request in rails
			},
			error: function() {
				show_error_msg(enable_submit_button(form_container).siblings("span:first"));
			},
			success: function(data, text_status) {
				var comment_attr_id = "comment_" + comment_id;
				var update_comments = $("#" + comment_attr_id).add("#" + compute_id_for_part(comment_attr_id));

				var content_containers = update_comments.find(".resume_comment_content:first");
				content_containers.html(
					$('<pre class="preformatted_content"></pre>').html(data)
				);
				
				$(update_comments).find("a").css("color", LINK_COLOR);
			}
		}
	);
}


function check_revision_form(container, type_name) {
	if(type_name == "edu" && $.trim($(container).find("[name='edu_period']:first").val()).length <= 0) {
		fail_msg("请输入时间段 ...");
		return false;
	}
	if(type_name.indexOf("_exp") >= 0) {
		if($.trim($(container).find("[name='exp_period']:first").val()).length <= 0) {
			fail_msg("请输入时间段 ...");
			return false;
		}
		if($.trim($(container).find("[name='exp_title']:first").val()).length <= 0) {
			fail_msg("请输入标题 ...");
			return false;
		}
		if($.trim($(container).find("[name='exp_content']:first").val()).length <= 0) {
			fail_msg("请输入内容 ...");
			return false;
		}
	}
	if(type_name.indexOf("_skill") >= 0 && $.trim($(container).find("[name='skill_name']:first").val()).length <= 0) {
		fail_msg("请输入名称 ...");
		return false;
	}
	if(type_name == "list_section") {
		if($.trim($(container).find("[name='section_title']:first").val()).length <= 0) {
			fail_msg("请输入标题 ...");
			return false;
		}
		if($.trim($(container).find("[name='section_content']:first").val()).length <= 0) {
			fail_msg("请输入内容 ...");
			return false;
		}
	}
	
	return true;
}


function disable_submit_button(container) {
	return $(container).find("input:submit")
		.attr("disabled", true)
		.addClass("ui-state-disabled")
		.val("正在提交 ...");
}


function enable_submit_button(container) {
	return $(container).find("input:submit")
		.val("提交")
		.removeClass("ui-state-disabled")
		.attr("disabled", false);
}


function show_error_msg(container) {
	return container
		.html("( 操作失败, 再试一次吧 ")
		.append(
			$('<a href="#"></a>')
				.addClass("none")
				.attr("title", "知道了, 让它消失吧")
				.html("x")
				.unbind("click").click(
					function() {
						$(this).parent().fadeOut();
						
						return false;
					}
				)
		)
		.append(" )")
		.fadeIn();
}


function collect_form_data(inputs) {
	var data = {};
	
	$.each(
		inputs,
		function(i, input) {
			data[$(input).attr("name")] = $(input).val();
		}
	);
	
	return data;
}


function setup_revisions(revisions) {
	$.each(
		revisions,
		function(i, revision) {
			$(revision).find("a.toggle_revision_link").unbind("click").click(
				function() {
					toggle_revision(revision);
					
					return false;
				}
			);
			
			
			$(revision).find("a.delete_revision_link").unbind("click").click(
				function() {
					confirm_msg(
						"确定要删除这条修改建议么 ?",
						function() {
							delete_revision(revision);
						}
					);
					
					return false;
				}
			);
			
			
			$(revision).find("a.edit_revision_link").unbind("click").click(
				function() {
					var content_container = $(revision).find(".resume_revision_content:first");
					
					content_container.find(".resume_revision_data").hide();
					content_container.find(".resume_revision_diff").hide();
					$(revision).find("button.diff_revision_btn").removeClass("ui-state-active");
					var revision_form = content_container.find(".resume_revision_form");
					if(revision_form.length <= 0) {
						revision_form = $('<div class="resume_revision_form"></div>').appendTo(content_container);
					}
					revision_form.html(get_edit_revision_form(revision)).show();
					
					return false;
				}
			);
			
			
			APP.setup_dropdown_menu($(revision).find("a.dropdown_menu_link"), 100);
			setup_update_applied_link(revision);
			beautify_buttons(
				$(revision).find(".resume_revision_actions button"),
				"1px 2px"
			);
			$(revision).find("button.diff_revision_btn").unbind("click").click(
				function() {
					var content_container = $(revision).find(".resume_revision_content:first");
					
					var diff = $(revision).find(".resume_revision_diff:first");
					if(diff.length > 0) {
						if(diff.is(":visible")) {
							content_container.find(".resume_revision_form").hide();
							content_container.find(".resume_revision_diff").hide();
							$(this).removeClass("ui-state-active");
							content_container.find(".resume_revision_data").show();
						}
						else {
							content_container.find(".resume_revision_form").hide();
							content_container.find(".resume_revision_data").hide();
							content_container.find(".resume_revision_diff").show();
							$(this).addClass("ui-state-active");
						}
					}
					else {
						diff_revision(revision);
					}
				}
			);
			$(revision).find("button.ignore_revision_btn").unbind("click").click(
				function() {
					update_revision_applied(revision, true, true);
				}
			);
			$(revision).find("button.apply_revision_btn").unbind("click").click(
				function() {
					var question = "确定要应用这条修改建议么 ? 简历内容将被相应地改变";
					var action = $(revision).find("input:hidden:nth-child(2)").val();
					
					if(action == "delete") {
						question = "删除段落后, 所有针对此段落的其他修改建议都将失效, 建议先应用针对此段落的其他修改建议. 确定要应用这条修改建议么 ?";
					}
					else if(action == "update") {
						var target_part_id = $(revision).find("input:hidden:first").val();
						var type_name = target_part_id.substring(0, target_part_id.lastIndexOf("_"));
						if(type_name == "student_exp") {
							question = "这条修改建议将修改一条经历库中的经历, 所有包含此经历的简历都将被改变 ! 确定要应用这条修改建议么 ?";
						}
					}
					
					confirm_msg(
						question,
						function() {
							apply_revision(revision);
						}
					);
				}
			);
			
			
			var part_title_field = $(revision).find(".target_part_title span:last");
			if(part_title_field.length > 0) {
				var target_part_id = $(revision).find("input:hidden:first").val();
				var target_part = $("#" + target_part_id);
				if(target_part.length > 0) {
					var type_name = target_part_id.substring(0, target_part_id.lastIndexOf("_"));
					part_title_field.html(get_dialog_title(target_part, type_name));
					
					$(revision).find(".resume_revision_actions table").show();
					
					$(revision).removeClass("info");
				}
				else {
					part_title_field.html($('<i></i>').html("(已被删除)"));
					
					$(revision).find(".resume_revision_actions table").hide();
			
					$(revision).addClass("info");
					toggle_revision(revision, false, false);
					
					if(is_revision_unapplied(revision)) {
						set_revision_applied(revision, true);
						UNAPPLIED_PART_DELETED_REVISIONS.push(revision);
					}
				}
			}
			
			
			$(revision).find("a").css("color", LINK_COLOR);
		}
	);
	
	return revisions;
}


function setup_update_applied_link(revisions) {
	$.each(
		$(revisions),
		function(i, revision) {
			var applied = !is_revision_unapplied(revision);
			$(revision).find("a.update_applied_link")
				.html(applied ? "尚未应用" : "已被应用")
				.unbind("click").click(
					function() {
						update_revision_applied(revision, !applied, false);

						return false;
					}
				);

			if(applied) {
				$(revisions).find(".ignore_revision_btn").add($(revisions).find(".apply_revision_btn")).hide();
			}
			else {
				$(revisions).find(".ignore_revision_btn").add($(revisions).find(".apply_revision_btn")).show();
			}
		}
	);
	
	return revisions;
}


function toggle_revision(revision, show, animation) {
	var revision_content = $(revision).find(".resume_revision_body");
	if(show == null) { show = !revision_content.is(":visible") }
	
	if(show) {
		if(animation == false) {
			revision_content.show();
		}
		else {
			revision_content.slideDown();
		}

		$(revision).find("a.toggle_revision_link img:first").attr("src", "/images/corporations/collapse_icon.gif");
	}
	else {
		if(animation == false) {
			revision_content.hide();
		}
		else {
			revision_content.slideUp();
		}

		$(revision).find("a.toggle_revision_link img:first").attr("src", "/images/corporations/expand_icon.gif");
	}
}


function delete_revision(revision) {
	var revision_id = parseInt($(revision).attr("id").substr("revision_".length));
	$.post(
		"/" + ACCOUNT_TYPE + "/" + ACCOUNT_ID + "/revise_resumes/" + RESUME_ID + "/revisions/" + revision_id,
		{
			_method: "delete" // simulate HTTP delete request in rails
		},
		function(data) {
			var revision_attr_id = "revision_" + revision_id;
			
			
			// adjust pop count
			if(is_revision_unapplied($("#" + revision_attr_id))) {
				adjust_revision_pop_count($("#" + revision_attr_id).find("input:hidden:first").val(), -1);
			}
			
			
			var removed_revisions = $("#" + revision_attr_id).add("#" + compute_id_for_part(revision_attr_id));
			removed_revisions.fadeOut(
				"slow",
				function() {
					removed_revisions.remove();
				}
			);
		},
		"html"
	);
}


function update_revision_applied(revision, applied, toggle) {
	var revision_id = parseInt($(revision).attr("id").substr("revision_".length));
	$.post(
		"/" + ACCOUNT_TYPE + "/" + ACCOUNT_ID + "/revise_resumes/" + RESUME_ID + "/revisions/" + revision_id + "/update_applied",
		{
			applied: applied ? 1 : 0
		},
		function(data) {
			update_revision_applied_locally(revision, applied, toggle);
		},
		"html"
	);
}


function update_revision_applied_locally(revision, applied, toggle) {
	var revision_attr_id = "revision_" + parseInt($(revision).attr("id").substr("revision_".length));
	var update_revisions = $("#" + revision_attr_id).add("#" + compute_id_for_part(revision_attr_id));
	
	set_revision_applied(update_revisions, applied);
	
	setup_update_applied_link(update_revisions);
	
	
	// adjust pop count
	adjust_revision_pop_count($(revision).find("input:hidden:first").val(), (applied ? -1 : 1));
	
	
	if(toggle) {
		toggle_revision(revision, !applied, true);
	}
}


function unapplied_class_name() {
	return "resume_revision_unapplied";
}


function is_revision_unapplied(revision) {
	return $(revision).hasClass(unapplied_class_name());
}


function set_revision_applied(revisions, applied) {
	if(applied) {
		return $(revisions).removeClass(unapplied_class_name());
	}
	else {
		return $(revisions).addClass(unapplied_class_name());
	}
}


function diff_revision(revision) {
	var revision_id = parseInt($(revision).attr("id").substr("revision_".length));
	$.get(
		"/" + ACCOUNT_TYPE + "/" + ACCOUNT_ID + "/revise_resumes/" + RESUME_ID + "/revisions/" + revision_id + "/diff",
		{},
		function(data) {
			var revision_attr_id = "revision_" + revision_id;
			var update_revisions = $("#" + revision_attr_id).add("#" + compute_id_for_part(revision_attr_id));
			
			update_revisions.find(".resume_revision_diff").remove();
			
			var content_containers = update_revisions.find(".resume_revision_content:first");
			content_containers.find(".resume_revision_form").hide();
			content_containers.find(".resume_revision_data").hide();
			content_containers.append($('<div class="resume_revision_diff"></div>').html(data));
			update_revisions.find("button.diff_revision_btn").addClass("ui-state-active");
		},
		"html"
	);
}


function clear_resume_revision_diff(revision) {
	var revision_id = parseInt($(revision).attr("id").substr("revision_".length));
	var revision_attr_id = "revision_" + revision_id;
	var update_revisions = $("#" + revision_attr_id).add("#" + compute_id_for_part(revision_attr_id));
	
	update_revisions.find(".resume_revision_diff").remove();
	update_revisions.find(".resume_revision_data").show();
	
	update_revisions.find("button.diff_revision_btn").removeClass("ui-state-active");
}


function apply_revision(revision) {
	var revision_id = parseInt($(revision).attr("id").substr("revision_".length));
	var revision_attr_id = "revision_" + revision_id;
	var update_revisions = $("#" + revision_attr_id).add("#" + compute_id_for_part(revision_attr_id));
	update_revisions.find("button.apply_revision_btn")
		.attr("disabled", true)
		.addClass("ui-state-disabled");
	
	
	var params = {};
	var target_part_id = $(revision).find("input:hidden:first").val();
	var type_name = target_part_id.substring(0, target_part_id.lastIndexOf("_"));
	if(type_name.indexOf("_exp") >= 0) {
		params["section"] = $("#" + target_part_id).parent().parent().attr("id").substr("exp_section_".length);
	}
	
	$.ajax(
		{
			type: "POST",
			url: "/" + ACCOUNT_TYPE + "/" + ACCOUNT_ID + "/revise_resumes/" + RESUME_ID + "/revisions/" + revision_id + "/apply",
			dataType: "json",
			data: params,
			success: function(result, text_status) {
				var action = result.action;
				var target = result.target;
				
				apply_revision_locally(action, target, result.data);

				update_revision_applied_locally(revision, true, true);
				
				if(action == "delete") {
					$("#dialog").dialog("close");
				}
				
				setup_revisions($(".resume_revision." + target));
				setup_comments($(".resume_comment." + target));

				clear_resume_revision_diff(revision);
			},
			complete: function() {
				update_revisions.find("button.apply_revision_btn")
					.removeClass("ui-state-disabled")
					.attr("disabled", false);
			}
		}
	);
}


function apply_revision_locally(action, target, data) {
	var part = $("#" + target);
	var type_name = target.substring(0, target.lastIndexOf("_"));
	
	if(action == "delete") {
		if(part.hasClass("resume_section")) {
			part.parent().remove();
		}
		else {
			if(part.siblings().length > 0) {
				part.remove();
			}
			else {
				var section = ancestor_with_class(part, "resume_section");
				if(section) {
					section.parent().remove();
				}
			}
		}
	}
	else {
		var part_template = part;
		if(action == "add") {
			if(type_name == "list_section") {
				part_template = part.parent().clone();
				part_template.find(".resume_section").attr("id", type_name + "_" + data.id);
			}
			else {
				part_template = part.clone().attr("id", type_name + "_" + data.id);
			}
		}
		
		// fill contents
		fill_resume_part(type_name, part_template, data);
		
		// resize the highlighter
		show_highlighter(1, part);
		
		if(action == "add") {
			if(part.hasClass("resume_section")) {
				part.parent().parent().append(part_template);
			}
			else {
				part.parent().append(part_template);
			}
		}
		
		
		if(type_name == "list_section") {
			setup_resume_part(type_name, part_template.find(".resume_section"));
		}
		else {
			setup_resume_part(type_name, part_template);
		}
	}
}


function fill_resume_part(type_name, part, data) {
	if(type_name == "edu") {
		$(part).find("td:nth-child(1)").text(data.period);
		$(part).find("td:nth-child(2)").text(data.university);
		$(part).find("td:nth-child(3)").text(data.college);
		$(part).find("td:nth-child(4)").text(data.major);
		$(part).find("td:nth-child(5)").text(data.edu_type);
	}
	else if(type_name.indexOf("_exp") >= 0) {
		$(part).find(".resume_exp_period").text(data.period);
		$(part).find(".resume_exp_title").text(data.title);
		$(part).find(".resume_exp_sub_title").text(data.sub_title);
		fill_list_content(part, data.content);
	}
	else if(type_name.indexOf("_skill") >= 0) {
		$(part).find("td:nth-child(1)").text(data.name);
		$(part).find("td:nth-child(2)").text(data.level);
	}
	else if(type_name == "list_section") {
		$(part).find(".resume_section_title").text(data.title);
		fill_list_content(part, data.content);
	}
	else if(type_name == "award" || type_name == "hobby") {
		fill_list_content(part, data.content);
	}
	else if(type_name == "exp_section_title") {
		$(part).text(data.title);
	}
	else {
		$(part).text(data.content);
	}
}


function fill_list_content(part, content) {
	var ul = $(part).find("ul").html("");
	$.each(
		content,
		function(i, line) {
			$('<li></li>').text(line).appendTo(ul);
		}
	);
}


function setup_new_comment_form() {
	$.each(
		beautify_buttons(
			$("#new_overall_comment, #new_comment, #new_overall_comment_in_dialog").find("input:submit:first"),
			BTN_PADDING_SMALL
		),
		function(i, button) {
			$(button).unbind("click").click(
				function() {
					var data = {};
					$.each(
						$(this).parent().siblings("input:hidden"),
						function(i, input) {
							data[$(input).attr("id")] = $(input).val();
						}
					);

					create_comment(
						$(this).parent().parent().find("textarea:first"),
						$(this).siblings("span:first"),
						data
					);
				}
			).siblings("a:first").unbind("click").click(
				function() {
					$(this).parent().parent().find("textarea:first").val("");

					return false;
				}
			);
		}
	);
}


function create_comment(text_field, error_container, data) {
	if($.trim(text_field.val()).length > 1000) {
		return fail_msg("内容超过长度限制 ...");
	}
	if($.trim(text_field.val()).length <= 0) {
		return fail_msg("请输入内容 ...");
	}
	
	
	var button_container = error_container.parent();
	disable_submit_button(button_container);
	error_container.hide();
	
	$.ajax(
		{
			type: "POST",
			url: "/" + ACCOUNT_TYPE + "/" + ACCOUNT_ID + "/revise_resumes/" + RESUME_ID + "/comments",
			dataType: "html",
			data: $.extend(
				{
					content: text_field.val(),
					involved_teachers: involved_teachers
				},
				data
			),
			error: function() {
				enable_submit_button(button_container);
				show_error_msg(error_container);
			},
			success: function(data, text_status) {
				// clear form inputs
				enable_submit_button(button_container);
				text_field.val("");
				
				// append comment html
				var comment_attr_id = $(data).attr("id");
				var target_part_id = setup_comments($(data)).appendTo($("#all_comments"))
										.find("input:hidden:first").val();
				
				var target_part = $("#" + target_part_id);
				if(target_part.length > 0) {
					// part comment created
					target_part.click();
					$("#dialog .tabs").tabs("select", "#part_comments");
					$("#part_comments").scrollTop($("#part_comments")[0].scrollHeight);
				}
				else {
					// overall comment created
					$("#overall_tabs.tabs").tabs("select", "#all_comments");
					$(document).scrollTop($(document).height());
					
					overall_comment_pop_click_handler();
					$("#overall_comment_dialog .tabs").tabs("select", "#overall_comments");
					$("#overall_comments").scrollTop($("#overall_comments")[0].scrollHeight);
				}
				
				// fade in effect
				$("#" + comment_attr_id)
				.add("#" + compute_id_for_part(comment_attr_id))
					.css("opacity", 0).animate({opacity: 1}, "slow");
				
				
				// adjust pop count
				adjust_comment_pop_count(target_part_id, 1);
			}
		}
	);
}


function setup_comments(comments) {
	$.each(
		comments,
		function(i, comment) {
			$(comment).find("a.toggle_revision_link").unbind("click").click(
				function() {
					toggle_revision(comment);
					
					return false;
				}
			);
			
			
			$(comment).find("a.delete_comment_link").unbind("click").click(
				function() {
					confirm_msg(
						"确定要删除么 ?",
						function() {
							delete_comment(comment);
						}
					);
					
					return false;
				}
			);
			
			
			$(comment).find("a.edit_comment_link").unbind("click").click(
				function() {
					var content_container = $(comment).find(".resume_comment_content:first");
					
					content_container.find("pre.preformatted_content").hide();
					var comment_form = content_container.find(".resume_comment_form");
					if(comment_form.length <= 0) {
						comment_form = $('<div class="resume_comment_form"></div>').appendTo(content_container);
					}
					comment_form.html(get_edit_comment_form(comment)).show();
					
					return false;
				}
			);
			
			
			var part_title_field = $(comment).find(".target_part_title span:last");
			if(part_title_field.length > 0) {
				var target_part_id = $(comment).find("input:hidden:first").val();
				var target_part = $("#" + target_part_id);
				if(target_part.length > 0) {
					var type_name = target_part_id.substring(0, target_part_id.lastIndexOf("_"));
					part_title_field.html(get_dialog_title(target_part, type_name));
				}
				else {
					if($.trim(target_part_id) == "_") {
						part_title_field.html("(整份简历)");
					}
					else {
						part_title_field.html($('<i></i>').addClass("info").html("(已被删除)"));
						toggle_revision(comment, false, false);
					}
				}
			}
			
			
			$(comment).find("a").css("color", LINK_COLOR);
		}
	);
	
	return comments;
}


function delete_comment(comment) {
	var comment_id = parseInt($(comment).attr("id").substr("comment_".length));
	$.post(
		"/" + ACCOUNT_TYPE + "/" + ACCOUNT_ID + "/revise_resumes/" + RESUME_ID + "/comments/" + comment_id,
		{
			_method: "delete" // simulate HTTP delete request in rails
		},
		function(data) {
			var comment_attr_id = "comment_" + comment_id;
			
			
			// adjust pop count
			adjust_comment_pop_count($("#" + comment_attr_id).find("input:hidden:first").val(), -1);
			
			
			var removed_comments = $("#" + comment_attr_id).add("#" + compute_id_for_part(comment_attr_id));
			removed_comments.fadeOut(
				"slow",
				function() {
					removed_comments.remove();
				}
			);
		},
		"html"
	);
}


function adjust_pop_count(part_attr_id, key, n) {
	var pop = $("#" + compute_id_for_pop(part_attr_id, key));
	if($.trim(part_attr_id) == "_") {
		pop = $("#" + compute_id_for_pop("overall", "comment"));
	}
	
	var count = to_number(pop.html()) + n;
	pop.html(count);
	if(count > 0) {
		pop.show();
	}
	else {
		pop.hide();
	}
}


function adjust_revision_pop_count(part_attr_id, n) {
	adjust_pop_count(part_attr_id, "revision", n);
}


function adjust_comment_pop_count(part_attr_id, n) {
	adjust_pop_count(part_attr_id, "comment", n);
}


function fail_msg(msg) {
	$('<div></div>')
		.css(
			{
				padding: "20px",
				color: "#CD0A0A"
			}
		)
		.html('<span class="ui-icon ui-icon-alert" style="margin: 2px 8px 0px 0px; float: left;"></span>')
		.append(msg)
		.dialog(
			{
				title: "操作失败",
				minWidth: 300,
				modal: true,
				close: function() {
					$(this).dialog("destroy").remove();
				},
				buttons: {
					"确定": function() {
						$(this).dialog("destroy").remove();
					}
				}
			}
		);
}


function confirm_msg(msg, func) {
	$('<div></div>')
		.css(
			{
				padding: "20px",
				color: "#111111"
			}
		)
		.html('<span class="ui-icon ui-icon-alert" style="margin: 2px 8px 0px 0px; float: left;"></span>')
		.append(msg)
		.dialog(
			{
				title: "操作确认",
				minWidth: 300,
				width: 400,
				modal: true,
				close: function() {
					$(this).dialog("destroy").remove();
				},
				buttons: {
					"确定": function() {
						$(this).dialog("destroy").remove();
						func.call();
					},
					"取消": function() {
						$(this).dialog("destroy").remove();
					}
				}
			}
		);
}


function is_ie6() {
	return (typeof document.body.style.maxHeight === "undefined")
}


$(document).ready(
	function() {
		APP.setup_dropdown_menu(".dropdown_menu_trigger", 150);
		
		setup_tabs();
		setup_dialog();
		setup_overall_comment_dialog();
		
		setup_revisions($(".resume_revision"));
		setup_comments($(".resume_comment"));
		setup_resume_parts();
		
		setup_new_comment_form();
		
		
		if(ACCOUNT_TYPE == "students" && UNAPPLIED_PART_DELETED_REVISIONS.length > 0) {
			set_revisions_to_applied(UNAPPLIED_PART_DELETED_REVISIONS);
		}
	}
);


function set_revisions_to_applied(revisions) {
	$.post(
		"/" + ACCOUNT_TYPE + "/" + ACCOUNT_ID + "/revise_resumes/" + RESUME_ID + "/revisions/set_applied",
		$.map(
			revisions,
			function(revision, i) {
				return "revisions[]=" + parseInt($(revision).attr("id").substr("revision_".length));
			}
		).join("&"),
		function(data) {
			// do nothing ...
		},
		"html"
	);
}


function request_revise_resume(teacher_id, teacher_name) {
	confirm_msg(
		"我们会尽快安排老师来修改你的简历, 确定发送请求 ?",
		function() {
			$.post(
				"/" + ACCOUNT_TYPE + "/" + ACCOUNT_ID + "/notifications/requests",
				{
					type: "revise_resume",
					teacher: teacher_id,
					resume: RESUME_ID
				},
				function(data) {
					// window.location.href = "";
					$('<form method="get" action=""></form>').appendTo($("body")).submit();
				},
				"html"
			);
		}
	);
}
