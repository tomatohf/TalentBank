function add_skill(skill_id, skill_link) {
	$.post(
		"/students/" + STUDENT_ID + "/add_skill",
		{
			skill_id: skill_id
		},
		function(data) {
			// add form input
			var row = document.getElementById("skill_row_" + skill_id);
			if(row) {
				$(row).replaceWith(data);
			}
			else {
				$("#skill_rows").prepend(data);
			}
			
			// adjust list
			$(".sep_line:first").before("<div class=\"selected_skill\">" + $(skill_link).html() + "</div>")
			$(skill_link).remove();
		},
		"html"
	);
}
