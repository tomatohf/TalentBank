function allow_teacher(teacher_id, allow_what) {
	var url = "/schools/" + SCHOOL_ID + "/allow_teacher_" + allow_what;
	adjust_teacher(url, teacher_id, allow_what);
}

function inhibit_teacher(teacher_id, inhibit_what) {
	var url = "/schools/" + SCHOOL_ID + "/inhibit_teacher_" + inhibit_what;
	adjust_teacher(url, teacher_id, inhibit_what);
}

function adjust_teacher(url, teacher_id, adjust_what) {
	show_loading(adjust_what);
	
	$.ajax(
		{
			type: "POST",
			url: url,
			dataType: "html",
			data: {
				teacher_id: teacher_id
			},
			complete: function() {
				hide_loading(adjust_what);
			},
			success: function(data, text_status) {
				$("#" + adjust_what + "_field_" + teacher_id).replaceWith(data);
				
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
