function adjust_permission(teacher, permission, allow) {
	show_permission_loading();
	
	$.ajax(
		{
			type: "POST",
			url: "/schools/" + SCHOOL_ID + "/adjust_teacher_permission",
			dataType: "html",
			data: {
				teacher: teacher,
				permission: permission,
				allow: allow
			},
			complete: function() {
				hide_permission_loading();
			},
			success: function(data, text_status) {
				$("#" + permission + "_field_" + teacher).replaceWith(data);
			}
		}
	);
}


function show_permission_loading() {
	$("#permission_loading").fadeIn("slow");
}

function hide_permission_loading() {
	$("#permission_loading").fadeOut("slow");
}


$(document).ready(
	function() {
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
