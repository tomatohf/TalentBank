var APP = {
	
	setup_dropdown_menu: function(selector, width, max_height) {
		if(width == null) { width = 150; }
		if(max_height == null) { max_height = 300; }
		$(selector).unbind("click").click(
			function() {
				var menu = $(this).parent().unbind("mouseenter mouseleave").hover(
					function() {},
					function() { $(this).parent().find("ul.dropdown_sub_menu").slideUp("slow"); }
				).find("ul.dropdown_sub_menu").css({width: width + "px", maxHeight: max_height + "px"});
				// to work around IE6 NOT support max-height
				menu.show().height((menu.height() > max_height) ? max_height : menu.height()).hide();
				menu.slideDown("fast");
				return false;
			}
		);
	},
	
	
	fill_colleges: function(university_id, college_id, college_empty_label, major_empty_label) {
		if(college_empty_label == null) college_empty_label = "不限学院";
		if(major_empty_label == null) major_empty_label = "不限专业";
		
		$("#college").html("");

		$("#college").append("<option value=''>" + college_empty_label + "</option>");

		var college_objs = COLLEGES["u_" + university_id];
		if(college_objs != null && college_objs.length > 0) {
			var options = $.map(
				college_objs,
				function(college_obj, i) {
					return "<option value='" + college_obj.id + "'>" + college_obj.name + "</option>";
				}
			);

			$("#college").append(options.join(""));

			$("#college").val(college_id);
		}

		this.fill_majors(college_id, "", major_empty_label);
	},
	fill_majors: function(college_id, major_id, empty_label) {
		if(empty_label == null) empty_label = "不限专业";
		
		$("#major").html("");

		$("#major").append("<option value=''>" + empty_label + "</option>");

		var major_objs = MAJORS["c_" + college_id];
		if(major_objs != null && major_objs.length > 0) {
			var options = $.map(
				major_objs,
				function(major_obj, i) {
					return "<option value='" + major_obj.id + "'>" + major_obj.name + "</option>";
				}
			);

			$("#major").append(options.join(""));

			$("#major").val(major_id);
		}
	},
	
	
	fill_industries: function(industry_selector, category_id, industry_id, empty_label) {
		if(empty_label == null) empty_label = "不限行业细分";
		
		$(industry_selector).html("");

		$(industry_selector).append("<option value=''>" + empty_label + "</option>");

		var industry_objs = INDUSTRIES["c_" + category_id];
		if(industry_objs != null && industry_objs.length > 0) {
			var options = $.map(
				industry_objs,
				function(industry_obj, i) {
					return "<option value='" + industry_obj.id + "'>" + industry_obj.name + "</option>";
				}
			);

			$(industry_selector).append(options.join(""));

			$(industry_selector).val(industry_id);
		}
	},
	
	
	fill_job_categories: function(job_category_selector, category_class_id, category_id, empty_label) {
		if(empty_label == null) empty_label = "不限岗位细分";
		
		$(job_category_selector).html("");

		$(job_category_selector).append("<option value=''>" + empty_label + "</option>");

		var job_category_objs = JOB_CATEGORIES["c_" + category_class_id];
		if(job_category_objs != null && job_category_objs.length > 0) {
			var options = $.map(
				job_category_objs,
				function(job_category_obj, i) {
					return "<option value='" + job_category_obj.id + "'>" + job_category_obj.name + "</option>";
				}
			);

			$(job_category_selector).append(options.join(""));

			$(job_category_selector).val(category_id);
		}
	},
	
	
	fill_intern_log_event_results: function(result_selector, event_id, result_id, empty_label) {
		if(empty_label == null) empty_label = "";
		
		$(result_selector).html("");

		$(result_selector).append("<option value=''>" + empty_label + "</option>");

		var result_objs = INTERN_LOG_EVENTS_RESULTS["e_" + event_id];
		if(result_objs != null && result_objs.length > 0) {
			var options = $.map(
				result_objs,
				function(result_obj, i) {
					return "<option value='" + result_obj.id + "'>" + result_obj.name + "</option>";
				}
			);

			$(result_selector).append(options.join(""));

			$(result_selector).val(result_id);
		}
	}
	
}


$(document).ready(
	function() {
		APP.setup_dropdown_menu("#setting_link", 100);
		APP.setup_dropdown_menu("#notification_link", 120);
	}
);
