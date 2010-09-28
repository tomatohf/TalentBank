function setup_number_input() {
	var number_input_tip = "请输入学号";
	
	$(".quick_form input#number").unbind("focus").unbind("blur")
		.focus(
			function() {
				if($.trim($(this).val()) == number_input_tip) {
					$(this).val("").css("color", "#000000");
				}
			}
		)
		.blur(
			function() {
				if($.trim($(this).val()) == "") {
					$(this).css("color", "#888888").val(number_input_tip);
				}
			}
		)
		.focus().blur()
		.parent("form").unbind("submit")
			.submit(
				function() {
					if($.trim($("input#number").val()) == number_input_tip) {
						$("input#number").val("");
					}
				}
			);
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


$(document).ready(
	function() {
		APP.setup_dropdown_menu(".operation_link", 130);
	
	
		$("#university").change(
			function() {
				APP.fill_colleges($(this).val(), "");
			}
		);
		$("#college").change(
			function() {
				APP.fill_majors($(this).val(), "");
			}
		);
		
		
		setup_toggle_search_form_link();
		
		setup_number_input();
	}
);
