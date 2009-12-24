var DIALOG_INIT_WIDTH = 500;
var DIALOG_INIT_HEIGHT = 400;

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
			
			show: null,
			hide: null,
			
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
	
	
	// make dialog title NOT wrap, and hide too long text
	$("span#ui-dialog-title-dialog").css(
		{
			width: "95%",
			overflow: "hidden",
			whiteSpace: "nowrap"
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


function setup_new_revision_buttons(type, part) {
	var type_name = type.name;
	var buttons_html = '建议:';
	if(type_name != "student_skill") {
		buttons_html += '<button id="action_update">修改内容</button>';
	}
	buttons_html += '<button id="action_delete">删除这段</button>';
	if(type_name != "job_intention" && type_name != "award" && type_name != "hobby") {
		buttons_html += '<button id="action_add">添加内容</button>';
	}
	$("#new_revision_actions").html(buttons_html);
	
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
				create_revision();
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
		if(type_name == "job_intention") {
			var input = '<input type="text" id="job_intention_content" />';
			input = $(input).addClass("text_field ui-corner-all").css(
				{
					width: "95%"
				}
			).val(modify ? $.trim($(part).html()) : "");
			$('<div></div>').append(input).appendTo(inputs_container);
		}
		else {
			var textarea = '<textarea rows="5"></textarea>';
			textarea = $(textarea)
				.attr("id", type_name)
				.addClass("text_field ui-corner-all")
				.css(
					{
						width: "95%"
					}
				).val(modify ? items_to_text($(part).find("ul")) : "");
			$('<div></div>').append(textarea).appendTo(inputs_container);
		}
	}
	
	add_submit_button(
		inputs_container,
		function() {
			create_revision();
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
	var label_column = $('<td></td>').css("width", "60px");
	$('<label></label>').attr("for", field_id).html(field_label).appendTo(label_column);
	
	var input_column = $('<td></td>');
	$(multi_line ? '<textarea rows="5"></textarea>' : '<input type="text" />')
		.attr("id", field_id)
		.addClass("text_field ui-corner-all")
		.css(
			{
				width: "95%"
			}
		)
		.val(field_value)
		.appendTo(input_column);
	
	return $('<tr></tr>').append(label_column).append(input_column);
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
}


function prepare_new_revision_content(type, part) {
	setup_new_revision_buttons(type, part);
	$("#new_revision_form").html("");
}


function create_revision() {
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
				enable_submit_button("#new_revision_form");
				
				alert("revision created");
			}
		}
	);
}


function disable_submit_button(container) {
	return $(container + " input:submit")
		.attr("disabled", true)
		.addClass("ui-state-disabled")
		.val("正在提交 ...");
}


function enable_submit_button(container) {
	return $(container + " input:submit")
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
			data[$(input).attr("id")] = $(input).val()
		}
	);
	
	return data;
}


$(document).ready(
	function() {
		setup_tabs();
		
		setup_resume_parts();
		
		setup_dialog();
	}
);
