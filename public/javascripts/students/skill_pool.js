function add_skill(skill_id, skill_link) {
	$.post(
		"/students/" + STUDENT_ID + "/add_skill",
		{
			skill_id: skill_id
		},
		function(data) {
			// add form input
			var row = $("#skill_row_" + skill_id);
			if(row.length > 0) {
				row.replaceWith(data);
			}
			else {
				$("#skill_rows").prepend(data);
			}
			handle_skill_input();
			
			// adjust list
			var selected_skill_id = "selected_skill_" + skill_id;
			var selected_skill_html = "<div class='selected_skill' id='" + selected_skill_id + "'>" + $(skill_link).html() + "</div>";
			var selected_skill = $("#" + selected_skill_id);
			if(selected_skill.length > 0) {
				selected_skill.replaceWith(selected_skill_html);
			}
			else {
				$(".skill_pool_sep_line:first").before(selected_skill_html);
			}
			$(skill_link).remove();
		},
		"html"
	);
}


function remove_skill(skill_id) {
	var skill_name = $.trim($("#selected_skill_" + skill_id).html());
	if(!confirm("确定要删除 " + skill_name + " 么 ?")) {
		return;
	}
	
	$.post(
		"/students/" + STUDENT_ID + "/remove_skill",
		{
			skill_id: skill_id
		},
		function(data) {
			// remove form input
			$("#skill_row_" + skill_id).remove();
			
			// remove from modified skill array
			MODIFIED_SKILLS = remove_from_array(skill_id + "", MODIFIED_SKILLS);
			
			// adjust list
			var selected_skill = $("#selected_skill_" + skill_id);
			$(".skill_pool_sep_line:first").after("<a href='#' class='unselected_skill' onclick='add_skill(" + skill_id + ", this); return false;'>" + selected_skill.html() + "</a>")
			selected_skill.remove();
		},
		"html"
	);
}


function handle_skill_input() {
	var skill_input_rows = $("tr[id^='skill_row_']");
	skill_input_rows.unbind("mouseenter mouseleave").hover(
		function() {
			$(this).find("a.none").show();
		},
		function() {
			$(this).find("a.none").hide();
		}
	);
	
	skill_input_rows.find("input,select,textarea").unbind("change").change(
		function() {
			var skill_row_id = $(this).parent().parent().attr("id");
			var skill_id = skill_row_id.substr("skill_row_".length);
			if($.inArray(skill_id, MODIFIED_SKILLS) < 0) {
				MODIFIED_SKILLS.push(skill_id);
			}
		}
	);
}


function remove_from_array(value, array) {
	var new_array = [];
	for(var i=0; i<array.length; i++) {
		if(array[i] != value) {
			new_array.push(array[i]);
		}
	}
	return new_array;
}


$(document).ready(
	function() {
		handle_skill_input();
		
		$("#update_skill_form").submit(
			function() {
				$("#modified_skills").val(MODIFIED_SKILLS.join(","));
			}
		);
		
		$("#loading").ajaxStart(
			function() {
				$(this).show();
			}
		);
		$("#loading").ajaxStop(
			function() {
				$(this).hide();
			}
		);
	}
);
