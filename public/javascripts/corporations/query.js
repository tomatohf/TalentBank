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


function fill_domains(category_id, domain_id) {
	$("#domain").html("");

	var domain_objs = DOMAINS["c_" + category_id];
	if(domain_objs != null && domain_objs.length > 0) {
		var options = $.map(
			domain_objs,
			function(domain_obj, i) {
				return "<option value='" + domain_obj.id + "'>" + domain_obj.name + "</option>";
			}
		);

		$("#domain").append(options.join(""));
		
		$("#domain").val(domain_id);
	}
	
	show_tags($("#domain").val());
}


function show_tags(domain_id) {
	$.each(
		ALL_DOMAINS,
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
	var content = 	'<label for="query_name" style="margin-right: 10px;">' + 
						required_mark + ' 保存为(名称):' +
					'</label>' +
					'<input type="text" id="query_name" name="query_name" class="text_field" size="30" value="" />' +
					'';
					
	show_dialog(
		content,
		{ ok: "保存", cancel: "取消" },
		function(data) {
			do_save_query($("#query_name").val());
			
			return true;
		}
	);
}

function do_save_query(query_name) {
	$.post(
		"/corporations/" + CORPORATION_ID + "/corp_saved_queries",
		$("#query_form").serialize() + "&name=" + encodeURIComponent(query_name),
		function(data) {
			show_dialog(
				data,
				{ cancel: "确定" },
				null
			);
		},
		"html"
	);
}

function show_dialog(content, button_text, ok_event) {
	DIALOG.appear(
		{
			title: "保存查询",
			content: content,
			button_text: button_text,
			width: 400,
			margin_top: 150,
			fixed: true,
			data: {},
			modal: false,
			ok_event: ok_event
		}
	);
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
		
		
		$("#domain_category").change(
			function() {
				fill_domains($(this).val());
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
