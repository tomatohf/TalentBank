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

function del_resume_student_exp(section_id, resume_student_exp_id, exp_period) {
	if(confirm("确定要删除 " + exp_period + " 的经历么 ?")) {
		document.getElementById("resume_student_exp_id").value = resume_student_exp_id;
		
		var resume_student_exp_del_form = document.getElementById("del_resume_student_exp_form");
		resume_student_exp_del_form.action = "/students/" + STUDENT_ID + "/resumes/" + RESUME_ID + "/resume_exp_sections/" + section_id + "/destroy_resume_student_exp";
		resume_student_exp_del_form.submit();
	}
}



function add_tag(tag_id) {
	$.post(
		"/students/" + STUDENT_ID + "/resumes/" + RESUME_ID + "/add_exp_tag",
		{
			tag_id: tag_id
		},
		function(data) {
			$("#exp_tags").append(data);
			
			remove_exp_tag_icon_hover();
		},
		"html"
	);
}

function remove_tag(tagger_id, tagger_link) {
	$.post(
		"/students/" + STUDENT_ID + "/resumes/" + RESUME_ID + "/remove_exp_tag",
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


function adjust_exp_tags() {
	var scroll_top = $(document).scrollTop();
	
	$("#exp_tags").animate(
		{
			top: (scroll_top > 0) ? (scroll_top - 50 + "px") : "0px"
		}
	);
}



$(document).ready(
	function() {
		$(".add_exp_link").click(
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
		
		$(".resume_list_section_content").hover(
			function() {
				$(this).find("div.exp_operations").css("visibility", "visible");
				adjust_exp_tags();
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
		
		
		$("#loading").ajaxStart(
			function() {
				$(this).show();
				$("#tag_icon_img").hide();
			}
		);
		$("#loading").ajaxStop(
			function() {
				$(this).hide();
				$("#tag_icon_img").show();
			}
		);
		
		
		$(".tag_link").click(
			function() {
				adjust_exp_tags();
			}
		);
		
		
		$(".resume_exp_container").sortable(
			{
				items: "div.resume_list_section_content",
				handle: ".resume_exp_order_handle img",
				cursor: "move",
				containment: "parent",
				forceHelperSize: true,
				forcePlaceholderSize: true,
				//opacity: 1,
				placeholder: "resume_exp_drag_placeholder",
				revert: 200,
				tolerance: "pointer"
			}
		);
		$(".resume_exp_container .resume_exp_order_handle").disableSelection();
	}
);
