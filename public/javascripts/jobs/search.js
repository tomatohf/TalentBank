function setup_toggle_form_section() {
	$(".form_section_title").unbind("click").click(
		function() {
			var section_body = $(this).siblings(".form_section_body");
			if(section_body.css("display") == "none") {
				section_body.slideDown();
				$(this).css("backgroundImage", "url(/images/corporations/collapse_icon.gif)");
			}
			else {
				section_body.slideUp();
				$(this).css("backgroundImage", "url(/images/corporations/expand_icon.gif)");
			}
			return false;
		}
	);
}


function goto_job_requirements_link() {
	if($.trim(window.location.href).indexOf("?") > 0) {
		// $("html, body").animate({scrollTop: $("#job_requirements_link").position().top});
		$("html, body").scrollTop($("#job_requirements_link").position().top);
	}
}


function setup_matched_students_more_link() {
	$(".matched_students_more a:first").unbind("click").click(
		function() {
			$(this).hide().siblings("span:first").show();
			add_more_search_result($(this).parent().siblings("table:first"));
			
			return false;
		}
	);
}


function add_more_search_result(table) {
	var url = table.find(".mini_pagination a:first").attr("href").replace(/&page=\d*/i, ""),
		page = parseInt($("#current_page").val()),
		total = parseInt($("#total_page").val())
		next = page + 1,
		no_more_func = function() { table.siblings(".matched_students_more").hide(); };
	if(page < total) {
		$.ajax(
			{
				type: "GET",
				url: url,
				dataType: "html",
				data: {
					page: next
				},
				complete: function() {
					if(next < total) {
						table.siblings(".matched_students_more")
							.find("a:first").show().siblings("span:first").hide();
					}
					else {
						no_more_func();
					}
				},
				success: function(data, text_status) {
					table.find("tbody:first").append(data);
					$("#current_page").val(next);
					
					setup_matched_student_actions(table);
				}
			}
		);
	}
	else {
		no_more_func();
	}
}


function set_calling_mark(student_id, marking) {
	show_status_refreshing(student_id);
	
	var url = "/teachers/" + TEACHER_ID + "/students/" + student_id + "/intern_logs/";
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
			data: {
				refresh_status: true
			},
			success: function(data, text_status) {
				update_status_locally(student_id, data);
			}
		}
	);
}


function add_inform_interview_log(student_id) {
	DIALOG.appear(
		{
			title: "添加学生 " + $("#matched_student_" + student_id).find("td:first .student_name").text() + " 的通知面试记录",
			content: function dialog_content(container, url) {
				// remove height property to let content expand the container height
				container.css( { height: "" } );
				container.html(
					'<img src="/images/loading_icon.gif" border="0" title="操作中" alt="操作中" style="margin: 0px 8px -3px 15px;" />' +
					'正在载入, 请稍候 ...'
				);
				$.get(
					"/teachers/" + TEACHER_ID + "/students/" + student_id + "/intern_logs/new",
					{
						job_id: JOB_ID,
						event_id: INFORM_INTERVIEW_LOG_EVENT_ID
					},
					function(data) {
						container.html(data);
					},
					"html"
				);
			},
			button_text: { ok: "添加", cancel: "取消" },
			width: 400,
			margin_top: 125,
			fixed: false,
			data: {},
			modal: false,
			ok_event: function(data) {
				var form = $("form#log_form:first");
				
				// check occur_at field
				var occur_at_field = form.find("input#occur_at");
				if(!$.trim(occur_at_field.val()).match(/^\d{2,4}-\d{1,2}-\d{1,2}\s\d{1,2}/i)) {
					occur_at_field.siblings("div.info_with_icon").css("color", "#EE0000");
					return;
				}
				
				show_status_refreshing(student_id);
				$.ajax(
					{
						type: form.attr("method"),
						url: form.attr("action"),
						dataType: "html",
						data: form.serialize() + "&refresh_status=true",
						success: function(data, text_status) {
							update_status_locally(student_id, data);
						}
					}
				);
				
				return true;
			}
		}
	);
}


function refresh_status(student_id) {
	show_status_refreshing(student_id);
	
	$.ajax(
		{
			type: "POST",
			url: "/teachers/" + TEACHER_ID + "/students/" + student_id + "/intern_logs/refresh_matched_student_status",
			dataType: "html",
			data: {},
			success: function(data, text_status) {
				update_status_locally(student_id, data);
			}
		}
	);
}


function update_status_locally(student_id, data) {
	var student = $("#matched_student_" + student_id),
		data_dom = $("<tr>" + data + "</tr>"),
		data_intern_status = data_dom.find(".intern_status"),
		data_action = data_dom.find(".actions")
	
	if(data_intern_status.length > 0) {
		student.find(".intern_status").html(data_intern_status.html());
	}
	
	if(data_action.length > 0) {
		student.find(".actions").html(data_action.html());
		setup_matched_student_actions(student);
	}
}


function setup_matched_student_actions(container) {
	var get_student_id = function(link) {
		return link.siblings("input:hidden:first").val();
	}
	
	if(container == null || container.length <= 0) {
		container = $("body");
	}
	
	container.find("a.mark_calling_link").unbind("click").click(
		function() {
			set_calling_mark(get_student_id($(this)), true);
			
			return false;
		}
	);
	
	container.find("a.clear_calling_mark_link").unbind("click").click(
		function() {
			set_calling_mark(get_student_id($(this)), false);
			
			return false;
		}
	);
	
	container.find("a.add_inform_interview_log_link").unbind("click").click(
		function() {
			add_inform_interview_log(get_student_id($(this)));
			
			return false;
		}
	);
	
	container.find("a.refresh_status_link").unbind("click").click(
		function() {
			refresh_status(get_student_id($(this)));
			
			return false;
		}
	);
}


function show_status_refreshing(student_id) {
	$("#matched_student_" + student_id).find(".intern_status").html(
		'<img src="/images/loading_icon.gif" border="0" title="刷新中" alt="刷新中" style="margin-top: 25px;" />'
	);
}


$(document).ready(
	function() {
		$("#industry_category").unbind("change").change(
			function() {
				APP.fill_industries("#industry", $(this).val(), "");
			}
		);
		
		$("#job_category_class").unbind("change").change(
			function() {
				APP.fill_job_categories("#job_category", $(this).val(), "");
			}
		);
		
		setup_toggle_form_section();
		
		setup_matched_students_more_link();
		
		setup_matched_student_actions();
		
		goto_job_requirements_link();
	}
);
