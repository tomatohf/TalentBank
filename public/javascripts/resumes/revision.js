var DIALOG_INIT_WIDTH = 500;
var DIALOG_INIT_HEIGHT = 420;

var BTN_PADDING_BIG = "6px 10px 5px";
var BTN_PADDING_SMALL = "3px 6px 2px";


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
			
			$.each(
				$("[id^='" + type_name + "_']"),
				function(i, part) {
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
					
					
					var revision_count = $("#all_revisions .ui-widget-content." + part_attr_id).length;
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
			);
		}
	);
}


function get_section_title(part) {
	var section = ancestor_with_class(part, "resume_section");
	
	return section ? $.trim(section.prev(".resume_section_title").html()) : "";
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
	
	var width = $(".resume").width() - (padding_x*2);
	if($(part).attr("id").indexOf("job_intention") >= 0) {
		width = $(part).outerWidth() - (padding_x*2);
	}
	
	$("#highlighter_" + index)
		.css(
			{
				left: $(".resume").position().left + padding_x,
				top: $(part).position().top - padding_y,
				"z-index": (0-index)
			}
		)
		.height($(part).height() + (padding_y*2))
		.width(width)
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
			
			show: null,
			hide: null,
			
			width: DIALOG_INIT_WIDTH,
			height: DIALOG_INIT_HEIGHT,
			maxWidth: 950,
			maxHeight: 600,
			minWidth: 460,
			position: calculate_dialog_position(),
			
			modal: false,
			
			close: function() {
				hide_highlighter(1);
			},
			
			resize: function(event, ui) {
				adjust_tabs_content_height_by_dialog();
			},
			open: function(event, ui) {
				adjust_tabs_content_height_by_dialog();
			}
		}
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


function adjust_tabs_content_height_by_dialog() {
	$.each(
		$("#dialog").css("overflow", "hidden").find(".tabs > div"),
		function(i, div) {
			var dialog_h = $("#dialog").innerHeight();
			var tabs_nav_h = $("#dialog .tabs ul:first").outerHeight(true);
			var div_margin = to_number($(div).css("marginTop")) + to_number($(div).css("marginBottom"));
			var div_padding = to_number($(div).css("paddingTop")) + to_number($(div).css("paddingBottom"));
			var fix_h = 20;
			
			var div_h = dialog_h - tabs_nav_h - div_margin - div_padding - fix_h;
			
			$(div).height(div_h).css("overflow", "auto");
		}
	);
	
	
	if(is_ie6()) {
		$("#dialog").width($("#dialog").parent().width() - 28);
	}
}


function to_number(value) {
	var number = parseFloat(value);
	return isNaN(number) ? 0 : number;
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


function get_dialog_title(part, type_name) {
	var title = get_section_title(part);
	
	var sub_title = get_dialog_sub_title(type_name, part);
	if(sub_title != "") {
		title += " - " + sub_title;
	}
	
	return title;
}


function get_dialog_sub_title(type_name, part) {
	part = $(part).clone();
	$(part).find(".resume_revision_pop, .resume_comment_pop").remove();
	
	
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
	
	return $.trim(sub_title);
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
	
	return icon ? '<span class="ui-icon ' + icon + ' float_l" style="margin-right: 3px;"></span>' : '';
}


function setup_new_revision_buttons(type, part) {
	var type_name = type.name;
	var buttons_html = '建议:';
	if(type_name != "student_skill") {
		buttons_html += '<button id="action_update">' + get_action_icon("update") + '修改内容</button>';
	}
	buttons_html += '<button id="action_delete">' + get_action_icon("delete") + '删除这段</button>';
	if(type_name != "job_intention" && type_name != "award" && type_name != "hobby") {
		buttons_html += '<button id="action_add">' + get_action_icon("add") + '添加内容</button>';
	}
	$("#new_revision_actions").html(buttons_html);
	
	
	// IE 6 ...
	if(is_ie6()) {
		$.each(
			$("#new_revision_actions").find("button"),
			function(i, button) {
				$(button).css("width", 105);
			}
		);
	}
	
	
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
			
			$("#new_revision_actions")
				.html('<button>' + btn_label + '</button>')
				.find("button")
					.addClass("ui-state-active ui-corner-all")
					.css(
						{
							padding: BTN_PADDING_BIG,
							position: "relative",
							left: btn_left,
							width: (is_ie6() ? 105 :  null)
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
	
	var type_id_input = '<input type="hidden" id="revision_type_id" />';
	var part_id_input = '<input type="hidden" id="revision_part_id" />';
	var revision_action_input = '<input type="hidden" id="revision_action" />';
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
	part = $(part).clone();
	$(part).find(".resume_revision_pop, .resume_comment_pop").remove();
	
	
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
					modify ? get_section_title(part) : "",
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
		type_name == "job_intention" ||
		type_name == "award" || type_name == "hobby"
	) {
		var multi_line = (type_name != "job_intention");
		div_for_text_field(
			type_name,
			modify ? (multi_line ? items_to_text($(part).find("ul")) : $.trim($(part).html())) : "",
			multi_line
		).appendTo(inputs_container);
	}
	
	add_submit_button(
		inputs_container,
		function() {
			create_revision(type, part);
		},
		function() {
			prepare_new_revision_content(type, part);
			
			return false;
		}
	);
	
	return inputs_container;
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
			.attr("id", field_id)
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


function compute_id_for_part(id) {
	return id + "_part";
}


function compute_id_for_pop(part_attr_id, key) {
	return part_attr_id + "_" + key + "_pop";
}


function create_revision(type, part) {
	disable_submit_button("#new_revision_form");
	
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
				
				$("#dialog").scrollTop($("#dialog")[0].scrollHeight);
				
				// fade in effect
				$("#" + revision_attr_id)
				.add("#" + compute_id_for_part(revision_attr_id))
					.css("opacity", 0).animate({opacity: 1}, "slow");
				
				
				// adjust pop count
				if($("#" + revision_attr_id).hasClass("ui-widget-content")) {
					adjust_revision_pop_count($(part).attr("id"), 1);
				}
			}
		}
	);
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
			data[$(input).attr("id")] = $(input).val();
		}
	);
	
	return data;
}


function setup_revisions(revisions) {
	$.each(
		revisions,
		function(i, revision) {
			$(revision).find(".toggle_revision_link").unbind("click").click(
				function() {
					toggle_revision(revision);
					
					return false;
				}
			);
			
			
			$(revision).find(".delete_revision_link").unbind("click").click(
				function() {
					delete_revision(revision);
					
					return false;
				}
			);
			
			
			var part_title_field = $(revision).find(".target_part_title span:first");
			if(part_title_field.length > 0) {
				var target_part_id = $(revision).find("input:hidden:first").val();
				var target_part = $("#" + target_part_id);
				if(target_part.length > 0) {
					var type_name = target_part_id.substring(0, target_part_id.lastIndexOf("_"));
					part_title_field.html(get_dialog_title(target_part, type_name));
				}
				else {
					part_title_field.html($('<i></i>').html("(已被删除)"));
			
					$(revision).find("td, div, span").addClass("info");
					toggle_revision(revision, false, false);
				}
			}
		}
	);
	
	return revisions;
}


function toggle_revision(revision, show, animation) {
	var revision_content = $(revision).find(".resume_revision_content");
	if(show == null) { show = !revision_content.is(":visible") }
	
	if(show) {
		if(animation == false) {
			revision_content.show();
		}
		else {
			revision_content.slideDown();
		}

		$(revision).find(".toggle_revision_link img:first").attr("src", "/images/corporations/collapse_icon.gif");
	}
	else {
		if(animation == false) {
			revision_content.hide();
		}
		else {
			revision_content.slideUp();
		}

		$(revision).find(".toggle_revision_link img:first").attr("src", "/images/corporations/expand_icon.gif");
	}
}


function delete_revision(revision) {
	if(!confirm("确定要删除这条修改建议么 ?")) {
		return;
	}
	
	var revision_id = parseInt($(revision).attr("id").substr("revision_".length));
	$.post(
		"/" + ACCOUNT_TYPE + "/" + ACCOUNT_ID + "/revise_resumes/" + RESUME_ID + "/revisions/" + revision_id,
		{
			_method: "delete" // simulate HTTP delete request in rails
		},
		function(data) {
			var revision_attr_id = "revision_" + revision_id;
			
			
			// adjust pop count
			if($("#" + revision_attr_id).hasClass("ui-widget-content")) {
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


function setup_new_comment_form() {
	$.each(
		beautify_buttons(
			$("#new_overall_comment, #new_comment").find("input:submit:first"),
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
		return alert("内容超过字数限制 ...");
	}
	if($.trim(text_field.val()).length <= 0) {
		return alert("请输入内容 ...");
	}
	
	var button_container = error_container.parent();
	disable_submit_button(button_container);
	
	$.ajax(
		{
			type: "POST",
			url: "/" + ACCOUNT_TYPE + "/" + ACCOUNT_ID + "/revise_resumes/" + RESUME_ID + "/comments",
			dataType: "html",
			data: $.extend(
				{
					content: text_field.val()
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
				$("#" + target_part_id).click();
				
				// switch tab
				$("#dialog .tabs").tabs("select", "#part_comments");
				$("#overall_tabs.tabs").tabs("select", "#all_comments");
				
				if($("#" + target_part_id).length > 0) {
					$("#dialog").scrollTop($("#dialog")[0].scrollHeight);
				}
				else {
					$(document).scrollTop($(document).height());
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
			$(comment).find(".toggle_revision_link").unbind("click").click(
				function() {
					toggle_revision(comment);
					
					return false;
				}
			);
			
			$(comment).find(".delete_comment_link").unbind("click").click(
				function() {
					delete_comment(comment);
					
					return false;
				}
			);
			
			
			var part_title_field = $(comment).find(".target_part_title span:first");
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
		}
	);
	
	return comments;
}


function delete_comment(comment) {
	if(!confirm("确定要删除么 ?")) {
		return;
	}
	
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


function is_ie6() {
	return (typeof document.body.style.maxHeight === "undefined")
}


$(document).ready(
	function() {
		setup_revisions($(".resume_revision"));
		setup_comments($(".resume_comment"));
		
		setup_tabs();
		
		setup_resume_parts();
		
		setup_dialog();
		
		setup_new_comment_form();
	}
);
