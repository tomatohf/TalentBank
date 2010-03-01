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


function setup_toggle_search_form_link() {
	$("#toggle_search_form_link").unbind("click").click(
		function() {
			if($("#search_form").css("display") == "none") {
				$("#search_form").slideDown();
			
				$(this).css("backgroundImage", "url(/images/teachers/search/pack_icon.gif)");
			}
			else {
				$("#search_form").slideUp();
				
				$(this).css("backgroundImage", "url(/images/teachers/search/expand_icon.gif)");
			}
			
			return false;
		}
	);
}


function setup_uid_input() {
	var uid_input_tip = "请输入用户名";
	
	$("input#uid").unbind("focus").unbind("blur")
		.focus(
			function() {
				if($.trim($(this).val()) == uid_input_tip) {
					$(this).val("").css("color", "#000000");
				}
			}
		)
		.blur(
			function() {
				if($.trim($(this).val()) == "") {
					$(this).css("color", "#888888").val(uid_input_tip);
				}
			}
		)
		.focus().blur()
		.parent("form").unbind("submit")
			.submit(
				function() {
					if($.trim($("input#uid").val()) == uid_input_tip) {
						$("input#uid").val("");
					}
				}
			);
}


$(document).ready(
	function() {
		APP.setup_dropdown_menu(".statistics_link", 120);
		
		
		setup_toggle_search_form_link();
		
		setup_uid_input();
		
		
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
