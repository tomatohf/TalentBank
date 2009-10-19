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
		
		
		fill_majors(INIT_COLLEGE, INIT_MAJOR);
		show_tags(INIT_DOMAIN);
	}
);
