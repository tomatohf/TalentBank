function fill_majors(college_id, major_id) {
	$("#major_id").html("");

	$("#major_id").append("<option value=''>不限专业</option>");

	var major_objs = MAJORS["c_" + college_id];
	if(major_objs != null && major_objs.length > 0) {
		var options = $.map(
			major_objs,
			function(major_obj, i) {
				return "<option value='" + major_obj.id + "'>" + major_obj.name + "</option>";
			}
		);

		$("#major_id").append(options.join(""));

		$("#major_id").val(major_id);
	}
}


function setup_number_input() {
	var number_input_tip = "请输入学号";
	
	$("input#number").unbind("focus").unbind("blur")
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
		.focus().blur();
}


function setup_toggle_search_form_link() {
	$("#toggle_search_form_link").unbind("click").click(
		function() {
			var icon = $(this).find("img:first");
			if($("#search_form").css("display") == "none") {
				$("#search_form").slideDown();
			
				icon.attr("src", "/images/teachers/search/pack_icon.gif");
			}
			else {
				$("#search_form").slideUp();
				
				icon.attr("src", "/images/teachers/search/expand_icon.gif");
			}
		}
	);
}


$(document).ready(
	function() {
		APP.setup_dropdown_menu(".operation_link", 130);
	
	
		$("#college_id").change(
			function() {
				fill_majors($(this).val(), "");
			}
		);
		
		
		setup_toggle_search_form_link();
		
		setup_number_input();
	}
);