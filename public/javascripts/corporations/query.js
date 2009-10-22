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
			remove_skill_from_list(skill_id);
		},
		"html"
	);
}

function remove_skill_from_list(skill_id) {
	$("#skill_" + skill_id).remove();
}


function remove_skill(skill_id) {
	var query_skill = $("#query_skill_" + skill_id);
	var skill_name = query_skill.find("label").html();
	
	// remove skill input
	query_skill.remove();
	
	// adjust skill list
	var skill_option_id = "skill_" + skill_id;
	var option = "<option value='" + skill_id + "' id='" + skill_option_id + "'>" + skill_name + "</option>";
	var skill_option = document.getElementById(skill_option_id);
	if(skill_option) {
		$(skill_option).replaceWith(option);
	}
	else {
		$("#skill_list").append(option);
	}
}


function save_query() {
	var content = 	'<label for="query_name">' + 
						'保存为(名称):' + 
					'</label>' +
					'&nbsp;&nbsp;&nbsp;' +
					'<input type="text" id="query_name" name="query_name" class="text_field" size="30" value="" />' +
					'';
	DIALOG.appear(
		{
			title: "保存查询",
			content: content,
			button_text: { ok: "保存", cancel: "取消" },
			width: 400,
			margin_top: 150,
			fixed: true,
			data: {},
			modal: false,
			ok_event: function(data) {
				return true;
			}
		}
	);
}

function do_save_query() {
	
}


$(document).ready(
	function() {
		$("#query_form").submit(
			function() {
				$("#keyword").val(encodeURIComponent($("#keyword_input").val()));
			}
		);
		
		
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
				
				return false;
			}
		);
		
		
		$("#save_query_link").click(
			function() {
				save_query();
				
				return false;
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
		
		
		// remove selected skill from list
		$.each(
			$("#skills").find(".query_skill"),
			function(i, ele) {
				var skill_id = $(ele).attr("id").substr("query_skill_".length);
				remove_skill_from_list(skill_id);
			}
		);
	}
);
