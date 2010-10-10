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
				}
			}
		);
	}
	else {
		no_more_func();
	}
}


function mark_calling(student_id) {
	
}


function refresh_status(student_id) {
	$("#matched_student_" + student_id).find(".intern_status").html(
		'<img src="/images/loading_icon.gif" border="0" title="刷新中" alt="刷新中" style="margin-top: 25px;" />'
	);
	
	$.ajax(
		{
			type: "POST",
			url: "/teachers/" + TEACHER_ID + "/students/" + student_id + "/intern_logs/refresh_matched_student_status",
			dataType: "html",
			data: {},
			complete: function() {
				
			},
			success: function(data, text_status) {
				var student = $("#matched_student_" + student_id);
				var data_dom = $("<tr>" + data + "</tr>");
				
				student.find(".intern_status").html(data_dom.find(".intern_status").html());
				
				student.find(".actions").html(data_dom.find(".actions").html());
				setup_matched_student_actions(student);
			}
		}
	);
}


function setup_matched_student_actions(container) {
	if(container == null || container.length <= 0) {
		container = $("body");
	}
	
	container.find("a.mark_calling_link").unbind("click").click(
		function() {
			mark_calling($(this).siblings("input:hidden:first").val());
			return false;
		}
	);
	
	container.find("a.refresh_status_link").unbind("click").click(
		function() {
			refresh_status(
				$(this).siblings("input:hidden:first").val()
			);
			
			return false;
		}
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
