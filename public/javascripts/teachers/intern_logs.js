function dialog_content(container, url) {
	// remove height property to let content expand the container height
	container.css( { height: "" } );
	
	container.html(
		'<img src="/images/loading_icon.gif" border="0" title="操作中" alt="操作中" style="margin: 0px 8px -3px 15px;" />' +
		'正在载入, 请稍候 ...'
	);
	
	$.get(url, {}, function(data) { container.html(data); setup_log_form(); }, "html");
}

function new_log() {
	show_dialog(
		function(container) {
			dialog_content(
				container,
				"/teachers/" + TEACHER_ID + "/students/" + STUDENT_ID + "/intern_logs/new"
			);
		},
		"添加"
	);
	
	return false;
}

function edit_log(log_id) {
	show_dialog(
		function(container) {
			dialog_content(
				container,
				"/teachers/" + TEACHER_ID + "/students/" + STUDENT_ID + "/intern_logs/" + log_id + "/edit"
			);
		},
		"修改"
	);
}

function submit_log_form() {
	var form = $("form#log_form:first");
	
	show_operating();
	$.ajax(
		{
			type: form.attr("method"),
			url: form.attr("action"),
			dataType: "html",
			data: form.serialize(),
			complete: hide_operating,
			success: function(data, text_status) {
				var new_log = $(data),
					log_id = $.trim(new_log.attr("id")),
					tbody = $("#log_list tbody"),
					log = null;
					
				if(log_id != "") {
					log = tbody.find("#" + log_id);
				}
				
				if(log == null) {
					return;
				}
					
				if(log.length > 0) {
					log.fadeOut(
						"slow",
						function() {
							$(this).html(new_log.html()).fadeIn("slow");
							
							setup_operation_links();
						}
					);
				}
				else {
					var tr = tbody.prepend(new_log).find("tr:first").hide();
					if(tr.siblings("tr:first").hasClass("odd")) {
						tr.removeClass("odd");
					}
					tr.fadeIn("slow");
					
					setup_operation_links();
				}
			}
		}
	);
}

function show_dialog(content, submit_label, ok_event) {
	DIALOG.appear(
		{
			title: submit_label + "实习记录",
			content: content,
			button_text: { ok: submit_label, cancel: "取消" },
			width: 400,
			margin_top: 125,
			fixed: true,
			data: {},
			modal: false,
			ok_event: function(data) {
				submit_log_form();
				return true;
			}
		}
	);
}


function delete_log(log_id) {
	if(!confirm("确定要删除这条实习记录么 ?")) { return; }
	
	show_operating();
	$.ajax(
		{
			type: "POST",
			url: "/teachers/" + TEACHER_ID + "/students/" + STUDENT_ID + "/intern_logs/" + log_id,
			data: {
				_method: "delete"
			},
			complete: hide_operating,
			success: function(data, text_status) {
				$("#log_" + log_id).fadeOut(
					"slow",
					function() {
						$(this).remove();
					}
				);
			}
		}
	);
}


function setup_operation_links() {
	$("#new_log_link").unbind("click").click(new_log);
	
	$("a.delete_link").unbind("click").click(
		function() {
			delete_log($(this).siblings("input:hidden:first").val());
			
			return false;
		}
	);
	
	$("a.edit_link").unbind("click").click(
		function() {
			edit_log($(this).siblings("input:hidden:first").val());
			
			return false;
		}
	);
}


function setup_log_form() {
	$("#event").unbind("change").change(
		function() {
			APP.fill_intern_log_event_results("#result", $(this).val(), "");
		}
	);
	
	$("#corporation").autocomplete(
		{
			source: "/teachers/" + TEACHER_ID + "/corporations/autocomplete"
		}
	).autocomplete("widget").removeClass("ui-corner-all").addClass("ui-corner-tr ui-corner-bl ui-corner-br");
}


function set_calling_mark(marking) {
	var url = "/teachers/" + TEACHER_ID + "/students/" + STUDENT_ID + "/intern_logs/";
	if(marking) {
		url += "set_calling_mark";
	}
	else {
		url += "clear_calling_mark";
	}
	
	$.ajax(
		{
			type: "POST",
			url: url,
			dataType: "html",
			data: {},
			success: function(data, text_status) {
				$("#calling_mark").fadeOut(
					"slow",
					function() {
						$(this).html(data).fadeIn("slow");
						setup_calling_mark_link();
					}
				);
			}
		}
	);
}


function setup_calling_mark_link() {
	$("a.mark_calling_link").unbind("click").click(
		function() {
			set_calling_mark(true);
			return false;
		}
	);
	
	$("a.clear_calling_mark_link").unbind("click").click(
		function() {
			set_calling_mark(false);
			return false;
		}
	);
}


function hide_operating() {
	$("#operating").fadeOut("slow");
}
function show_operating() {
	$("#operating").fadeIn("slow");
}


$(document).ready(
	function() {
		setup_calling_mark_link();
		setup_operation_links();
	}
);
