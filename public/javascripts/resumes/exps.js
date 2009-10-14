function del_section(section_id, section_title) {
	if(confirm("确定要删除经历块 " + section_title + " 么 ? 该经历块中所有的经历都将被删除 !")) {
		var section_del_form = document.getElementById("del_section_form");
		section_del_form.action = "/students/" + STUDENT_ID + "/resumes/" + RESUME_ID + "/resume_exp_sections/" + section_id;
		section_del_form.submit();
	}
}

function del_exp(section_id, exp_id, exp_period) {
	if(confirm("确定要删除 " + exp_period + " 的经历么 ?")) {
		var exp_del_form = document.getElementById("del_exp_form");
		exp_del_form.action = "/students/" + STUDENT_ID + "/resumes/" + RESUME_ID + "/resume_exp_sections/" + section_id + "/resume_exps/" + exp_id;
		exp_del_form.submit();
	}
}



function add_tag(section_id, exp_id, tag_id) {
	$.post(
		"/students/" + STUDENT_ID + "/resumes/" + RESUME_ID + "/resume_exp_sections/" + section_id + "/resume_exps/" + exp_id + "/add_tag",
		{
			tag_id: tag_id
		},
		function(data) {
			$("#exp_tags_" + exp_id).append(data);
			
			remove_exp_tag_icon_hover();
		},
		"html"
	);
}

function remove_tag(section_id, exp_id, tagger_id, tagger_link) {
	$.post(
		"/students/" + STUDENT_ID + "/resumes/" + RESUME_ID + "/resume_exp_sections/" + section_id + "/resume_exps/" + exp_id + "/remove_tag",
		{
			tagger_id: tagger_id
		},
		function(data) {
			if(data != null && data.substr(0, 4)  == "true") {
				$(tagger_link).remove();
			}
		},
		"text"
	);
}

function remove_exp_tag_icon_hover() {
	$(".remove_exp_tag_link").hover(
		function() {
			$(this).find("img.remove_exp_tag_icon").css("visibility", "visible");
		},
		function() {
			$(this).find("img.remove_exp_tag_icon").css("visibility", "hidden");
		}
	);
}



$(document).ready(
	function() {
		$(".resume_list_section_content").hover(
			function() {
				$(this).find("div.exp_operations").css("visibility", "visible");
			},
			function() {
				$(this).find("div.exp_operations").css("visibility", "hidden");
			}
		);
		
		$(".tag_link").click(
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
		
		remove_exp_tag_icon_hover();
	}
);
