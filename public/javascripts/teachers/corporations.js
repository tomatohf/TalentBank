function adjust_permission(corporation_id, permission, allow) {
	show_permission_loading();
	
	$.ajax(
		{
			type: "POST",
			url: "/teachers/" + TEACHER_ID + "/adjust_corporation_permission",
			dataType: "html",
			data: {
				corporation_id: corporation_id,
				permission: permission,
				allow: allow
			},
			complete: function() {
				hide_permission_loading();
			},
			success: function(data, text_status) {
				$("#" + permission + "_field_" + corporation_id).replaceWith(data);
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
		APP.setup_dropdown_menu(".statistics_link", 120);
		
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
