function fill_majors(college_id, major_id) {
	$("#major").html("");
	
	var major_objs = MAJORS["c_" + college_id];
	if(major_objs != null && major_objs.length > 0) {
		var options = $.map(
			major_objs,
			function(major_obj, i) {
				return "<option value='" + major_obj.id + "'>" + major_obj.name + "</option>";
			}
		);
		
		$("#major").append("<option value=''></option>");
		$("#major").append(options.join(""));
		
		$("#major").val(major_id);
	}
}


function show_tags(domain_id) {
	$.each(
		DOMAINS,
		function(i, domain) {
			$("#tags_" + domain).hide();
		}
	);
	
	$("#tags_" + domain_id).fadeIn("fast");
}


function add_skill(skill_id) {
	$.post(
		"/corporations/" + CORPORATION_ID + "/add_skill",
		{
			skill_id: skill_id
		},
		function(data) {
			// add skill input
			var query_skill = document.getElementById("query_skill_" + skill_id);
			if(query_skill) {
				$(query_skill).replaceWith(data);
			}
			else {
				$("#skills").append(data);
			}
			
			// adjust skill list
			$("#skill_" + skill_id).remove();
		},
		"html"
	);
}


function remove_skill(skill_id, skill_name) {
	// remove skill input
	$("#query_skill_" + skill_id).remove();
	
	// adjust skill list
	var option = "<option value='" + skill_id + "' id='skill_" + skill_id + "'>" + skill_name + "</option>";
	$("#skill_list").append(option);
}


$(document).ready(
	function() {
		$("#college").change(
			function() {
				fill_majors($(this).val(), "");
			}
		);
		
		
		$("#domain").change(
			function() {
				show_tags($(this).val());
			}
		);
		
		
		$("#add_skill_link").click(
			function() {
				add_skill($("#skill_list").val());
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
		
		
		fill_majors(INIT_COLLEGE, INIT_MAJOR);
		show_tags(INIT_DOMAIN);
	}
);
