function del_teacher(teacher_id, uid) {
	if(confirm("确定要删除老师 " + uid + " 么 ?")) {
		show_loading("destroy");

		$.ajax(
			{
				type: "POST",
				url: "/schools/" + SCHOOL_ID + "/destroy_teacher",
				dataType: "text",
				data: {
					teacher_id: teacher_id
				},
				complete: function() {
					hide_loading("destroy");
				},
				success: function(data, text_status) {
					if(data != null && data.substr(0, 4) == "true") {
						$("#teacher_row_" + teacher_id).fadeOut(
							"slow",
							function() {
								$(this).remove();
							}
						);
					}
				}
			}
		);
	}
}

function allow_teacher_admin(teacher_id) {
	var url = "/schools/" + SCHOOL_ID + "/allow_teacher_admin";
	adjust_teacher_admin(url, teacher_id);
}

function inhibit_teacher_admin(teacher_id) {
	var url = "/schools/" + SCHOOL_ID + "/inhibit_teacher_admin";
	adjust_teacher_admin(url, teacher_id);
}

function adjust_teacher_admin(url, teacher_id) {
	show_loading("admin");
	
	$.ajax(
		{
			type: "POST",
			url: url,
			dataType: "html",
			data: {
				teacher_id: teacher_id
			},
			complete: function() {
				hide_loading("admin");
			},
			success: function(data, text_status) {
				$("#admin_field_" + teacher_id).replaceWith(data);
				
				setup_dropdown_menus();
			}
		}
	);
}


function show_loading(name) {
	$("#" + name + "_loading").css("visibility", "visible");
}

function hide_loading(name) {
	$("#" + name + "_loading").css("visibility", "hidden");
}


function setup_dropdown_menus() {
	$(".operation_link").unbind("click").click(
		function() {
			$(this).parent().find("ul.dropdown_sub_menu").slideDown("fast").show();

			$(this).parent().hover(
				function() {
				},
				function() {
					$(this).parent().find("ul.dropdown_sub_menu").slideUp("slow");
				}
			);
			
			return false;
		}
	);
}

function setup_mouse_over() {
	$(".teacher_row").unbind("mouseenter mouseleave").hover(
		function() {
			$(this).css("backgroundColor", "#F8F8F8");
		},
		function() {
			$(this).css("backgroundColor", "#FFFFFF");
		}
	);
}


$(document).ready(
	function() {
		setup_dropdown_menus();
		setup_mouse_over();
		
		// make success msg disappear some time later
		$(".success_msg").animate(
			{
				opacity: 90
			},
			5000,
			function() {
				$(".success_msg").animate(
					{
						opacity: 0
					},
					3000,
					function() {
						$(this).remove();
					}
				);
			}
		);
	}
);
