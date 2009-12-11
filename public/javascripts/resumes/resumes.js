function fill_domains(category_id) {
	$("#domain_id").html("");

	var domain_objs = DOMAINS["c_" + category_id];
	if(domain_objs != null && domain_objs.length > 0) {
		var options = $.map(
			domain_objs,
			function(domain_obj, i) {
				return "<option value='" + domain_obj.id + "'>" + domain_obj.name + "</option>";
			}
		);

		$("#domain_id").append(options.join(""));
	}
}


function copy_resume(from_resume_id, to_resume_id, from_domain_name, to_domain_name) {
	if(confirm("确定要将 " + from_domain_name + " 的简历内容复制到 " + to_domain_name + " 的简历么 ? " + to_domain_name + " 的简历中的现有内容将被全部清除 !")) {
		$("#copy_to_resume_id").val(to_resume_id);
		$("#copy_resume_form")
			.attr("action", "/students/" + STUDENT_ID + "/resumes/" + from_resume_id + "/copy")
			.submit();
	}
}


function del_resume(resume_id, domain) {
	if(confirm("确定要删除 " + domain + " 的简历么 ? 该简历中所有的数据都将被删除 !")) {
		$("#del_resume_form")
			.attr("action", "/students/" + STUDENT_ID + "/resumes/" + resume_id)
			.submit();
	}
}


function update_resume(resume_id, domain, online) {
	var msg = online ? "确定要将 " + domain + " 的简历上线么 ?" : "确定要将 " + domain + " 的简历下线么 ? 下线后该简历将无法被企业检索和浏览";
	if(confirm(msg)) {
		$("#online").val(online.toString());
		$("#update_resume_form")
			.attr("action", "/students/" + STUDENT_ID + "/resumes/" + resume_id)
			.submit();
	}
}


$(document).ready(
	function() {
		$(".edit_link").click(
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
		
		
		$("#domain_category").change(
			function() {
				fill_domains($(this).val());
			}
		);
	}
);
