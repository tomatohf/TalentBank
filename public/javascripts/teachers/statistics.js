var range_date_format = "y年m月d日";
var short_year_cutoff = 80;
var range_splitter = "-";

var period_date_format = "yymmdd";

var FILTERS = [
	"level", "graduation", "university", "college", "major", "student",
	"corp", "corp_industry_category", "corp_industry", "corp_nature",
	"domain", "tag", "skill", "keyword",
	"job_category_class", "job_category", "job_district"
];


function view_dot_detail(dot_index) {
	show_details("view", $("input#dot_" + dot_index).val(), {});
}


function query_dot_detail(dot_index) {
	show_details("query", $("input#dot_" + dot_index).val(), {});
}


function compared_view_dot_detail(dot_index) {
	show_details("view", $("input#compared_dot_" + dot_index).val(), {});
}


function compared_query_dot_detail(dot_index) {
	show_details("query", $("input#compared_dot_" + dot_index).val(), {});
}


function group_view_detail(value_index) {
	var extra_filters = get_extra_filters(value_index);
	
	if(extra_filters != null) {
		show_details("view", $("input#period").val(), extra_filters);
	}
}


function compared_group_view_detail(value_index) {
	var extra_filters = get_extra_filters(value_index);
	
	if(extra_filters != null) {
		show_details("view", $("input#compared_period").val(), extra_filters);
	}
}


function group_query_detail(value_index) {
	var extra_filters = get_extra_filters(value_index);
	
	if(extra_filters != null) {
		show_details("query", $("input#period").val(), extra_filters);
	}
}


function compared_group_query_detail(value_index) {
	var extra_filters = get_extra_filters(value_index);
	
	if(extra_filters != null) {
		show_details("query", $("input#compared_period").val(), extra_filters);
	}
}


function intern_logs_detail(event_id, result_id) {
	show_details(
		"intern_log", $("input#period").val(),
		{
			event_id: event_id,
			result_id: result_id
		}
	);
}


function compared_intern_logs_detail(event_id, result_id) {
	show_details(
		"intern_log", $("input#compared_period").val(),
		{
			event_id: event_id,
			result_id: result_id
		}
	);
}


function get_extra_filters(value_index) {
	var extra_filters = null;
	
	var group_value = $("input#group_value_" + value_index).val();
	if(group_value != null) {
		extra_filters = {};
		extra_filters[$("input#group_by_field").val()] = group_value;
	}
	
	return extra_filters;
}


function show_details(detail_type, detail_period, extra_filters) {
	show_details_dialog(
		function(container) {
			// remove height property to let content expand the container height
			container.css( { height: "" } );
			
			show_details_dialog_content(container, null, detail_type, detail_period, extra_filters);
		}
	);
}


function show_details_dialog_content(container, url, detail_type, detail_period, extra_filters) {
	if(url == null) {
		container.html(
			'<img src="/images/loading_icon.gif" border="0" title="操作中" alt="操作中" style="margin: 0px 8px -3px 15px;" />' +
			'正在载入, 请稍候 ...'
		);
	}
	
	var data = $.extend(
		{
			type: detail_type,
			period: detail_period
		},
		get_filter_values(),
		extra_filters
	);
	
	$.ajax(
		{
			type: "GET",
			url: url || ("/teachers/" + TEACHER_ID + "/statistics/details"),
			dataType: "html",
			data: data,
			error: function() {
				show_details_dialog('<p class="error_msg">载入失败, 再试一次吧</p>');
			},
			success: function(data, text_status) {
				container.html(data);
				
				setup_details_dialog_links(container, detail_type, detail_period, extra_filters);
			}
		}
	);
}


function setup_details_dialog_links(container, detail_type, detail_period, extra_filters) {
	$(".pagination a").unbind("click").click(
		function() {
			show_details_dialog_content(container, $(this).attr("href"), detail_type, detail_period, extra_filters);
			
			return false;
		}
	);
	$("a.query_keyword").unbind("click").click(
		function() {
			$(this).siblings("form").submit();

			return false;
		}
	);
	
	APP.setup_dropdown_menu(".operation_link", 120);
}


function show_details_dialog(content) {
	DIALOG.appear(
		{
			title: "详细数据列表",
			content: content,
			button_text: {
				cancel: "确定"
			},
			width: 800,
			margin_top: 30,
			fixed: false,
			data: {},
			modal: false,
			close: true
		}
	);
}


function change_view(view) {
	$("input#view").val(view);
	$("#refresh_form").submit();
}


function change_dataset(id, value) {
	$("input#" + id).val(value);
	$("#refresh_form").submit();
}


function change_order(order) {
	$("input#order").val(order);
	$("#refresh_form").submit();
}


function change_limit(limit) {
	if($("input#limit").val() != (limit+"")) {
		$("input#limit").val(limit);
		$("#refresh_form").submit();
	}
}


function change_compare(date_text) {
	$("input#compare").val(date_text);
	$("#refresh_form").submit();
}


function change_filter(id, value) {
	$("input#" + id).val(value);
	$("#refresh_form").submit();
}


function change_period() {
	disable_range_input();
	
	var ranges = $("input#date_range").val().split(range_splitter);
	if(ranges.length > 1) {
		var from = null;
		var to = null;
		try {
			from = $.datepicker.parseDate(range_date_format, $.trim(ranges[0]), {shortYearCutoff: short_year_cutoff});
			to = $.datepicker.parseDate(range_date_format, $.trim(ranges[1]), {shortYearCutoff: short_year_cutoff});
		}
		catch(e) {
			from = null;
			to = null;
		}
		if(from != null && to != null) {
			var new_period = [
				$.datepicker.formatDate(period_date_format, from),
				$.datepicker.formatDate(period_date_format, to)
			].join(range_splitter);
			
			// check whether changed ... to avoid refresh with same values
			if(new_period != $("input#period").val()) {
				$("input#period").val(new_period);
				$("#refresh_form").submit();
				
				return;
			}
		}
	}
	
	enable_range_input();
}


function disable_range_input() {
	$("input#date_range").attr("disabled", true)
	.parent().find("a").unbind("click", change_period);
}


function enable_range_input() {
	$("input#date_range").removeAttr("disabled")
	.parent().find("a").unbind("click", change_period).click(change_period);
}


function filter_level() {
	show_static_filter_dialog("level", LEVELS, "过滤学历");
}


function filter_graduation() {
	show_static_filter_dialog("graduation", GRADUATIONS, "过滤毕业时间");
}


function filter_university() {
	show_static_filter_dialog("university", UNIVERSITIES, "过滤大学");
}


function filter_college() {
	var college_objs = COLLEGES["u_" + $("input#university").val()];
	if(college_objs == null) {
		college_objs = [];
		$.each(
			COLLEGES,
			function(key, value) {
				$.merge(college_objs, value);
			}
		);
	}
	
	show_static_filter_dialog("college", college_objs, "过滤学院");
}


function filter_major() {
	var major_objs = MAJORS["c_" + $("input#college").val()];
	if(major_objs == null) {
		major_objs = [];
		$.each(
			MAJORS,
			function(key, value) {
				$.merge(major_objs, value);
			}
		);
	}
	
	show_static_filter_dialog("major", major_objs, "过滤专业");
}


function filter_student() {
	show_filter_dialog(filter_student_dialog_content, "过滤学生");
}


function filter_student_dialog_content(container, url) {
	if(url == null) {
		container.html(
			'<img src="/images/loading_icon.gif" border="0" title="操作中" alt="操作中" style="margin: 0px 8px -3px 15px;" />' +
			'正在载入, 请稍候 ...'
		);
	}
	
	$.ajax(
		{
			type: "GET",
			url: url || ("/teachers/" + TEACHER_ID + "/students"),
			dataType: "html",
			data: {
				u: $("input#university").val(),
				c: $("input#college").val(),
				m: $("input#major").val(),
				e: $("input#level").val(),
				g: $("input#graduation").val()
			},
			error: function() {
				show_filter_dialog('<p class="error_msg">载入失败, 再试一次吧</p>');
			},
			success: function(data, text_status) {
				container.html(data);
				
				setup_filter_links(container);
			}
		}
	);
}


function filter_corp() {
	show_filter_dialog(filter_corp_dialog_content, "过滤企业");
}


function filter_corp_dialog_content(container, url) {
	if(url == null) {
		container.html(
			'<img src="/images/loading_icon.gif" border="0" title="操作中" alt="操作中" style="margin: 0px 8px -3px 15px;" />' +
			'正在载入, 请稍候 ...'
		);
	}
	
	$.ajax(
		{
			type: "GET",
			url: url || ("/teachers/" + TEACHER_ID + "/corporations"),
			dataType: "html",
			data: {
				ic: $("input#corp_industry_category").val(),
				i: $("input#corp_industry").val(),
				n: $("input#corp_nature").val()
			},
			error: function() {
				show_filter_dialog('<p class="error_msg">载入失败, 再试一次吧</p>');
			},
			success: function(data, text_status) {
				container.html(data);
				
				setup_filter_links(container);
			}
		}
	);
}


function filter_corp_industry_category() {
	show_static_filter_dialog("corp_industry_category", INDUSTRY_CATEGORIES, "过滤企业行业大类");
}


function filter_corp_industry() {
	var corp_industry_objs = INDUSTRIES["c_" + $("input#corp_industry_category").val()];
	if(corp_industry_objs == null) {
		corp_industry_objs = [];
		$.each(
			INDUSTRIES,
			function(key, value) {
				$.merge(corp_industry_objs, value);
			}
		);
	}
	
	show_static_filter_dialog("corp_industry", corp_industry_objs, "过滤企业行业细分");
}


function filter_corp_nature() {
	show_static_filter_dialog("corp_nature", CORP_NATURES, "过滤企业性质");
}


function filter_domain() {
	show_static_filter_dialog("domain", DOMAINS, "过滤求职方向");
}


function filter_tag() {
	var tag_objs = TAGS["d_" + $("input#domain").val()];
	if(tag_objs == null) {
		tag_objs = [];
		$.each(
			TAGS,
			function(key, value) {
				$.merge(tag_objs, value);
			}
		);
	}
	
	show_static_filter_dialog("tag", tag_objs, "过滤经历标签");
}


function filter_skill() {
	show_static_filter_dialog("skill", SKILLS, "过滤技能和证书");
}


function filter_job_category_class() {
	show_static_filter_dialog("job_category_class", JOB_CATEGORY_CLASSES, "过滤岗位大类");
}


function filter_job_category() {
	var job_category_objs = JOB_CATEGORIES["c_" + $("input#job_category_class").val()];
	if(job_category_objs == null) {
		job_category_objs = [];
		$.each(
			JOB_CATEGORIES,
			function(key, value) {
				$.merge(job_category_objs, value);
			}
		);
	}
	
	show_static_filter_dialog("job_category", job_category_objs, "过滤岗位细分");
}


function filter_job_district() {
	show_static_filter_dialog("job_district", JOB_DISTRICTS, "过滤工作区域");
}


function setup_filter_links(container) {
	container.find("a[id^='filter_']").unbind("click").click(
		function() {
			var filter = $(this).attr("id").substr("filter_".length),
				last_underscore_index = filter.lastIndexOf("_"),
				filter_name = filter.substring(0, last_underscore_index),
				filter_value = filter.substring(last_underscore_index + 1);
			change_filter(filter_name, filter_value);
			// DIALOG.disappear();
			
			return false;
		}
	);
	
	
	container.find(".pagination a").unbind("click").click(
		function() {
			filter_corp_dialog_content(container, $(this).attr("href"));
			
			return false;
		}
	);
}


function show_filter_dialog(content, title) {
	DIALOG.appear(
		{
			title: title || "过滤",
			content: content,
			button_text: {},
			width: 400,
			margin_top: 80,
			fixed: false,
			data: {},
			modal: false,
			close: true
		}
	);
}


function show_static_filter_dialog(filter_name, filter_objs, title) {
	show_filter_dialog(
		function(container) {
			// remove height property to let content expand the container height
			container.css( { height: "" } );
			
			var links = $.map(
				filter_objs,
				function(filter_obj, i) {
					return '<a href="#" id="filter_' + filter_name + '_' + filter_obj.id + '" class="filter_item_link">' +
								filter_obj.name +
							'</a>';
				}
			);

			container.html(links.join(""));
			
			// adjust height to avoid beyond one page
			var max_h = 400;
			if(container.height() > max_h) { container.height(max_h); }
			
			setup_filter_links(container);
		},
		title
	);
}


function setup_toggle_intern_log_pie_chart_links() {
	$("a.toggle_intern_log_pie_chart_link").unbind("click").click(
		function() {
			var link = $(this);
			
			var chart_container = link.siblings("div");
			if(chart_container.css("display") == "none") {
				chart_container.slideDown("slow");
				link.text("隐藏饼图");
			}
			else {
				chart_container.slideUp("slow");
				link.text("显示饼图");
			}
			
			return false;
		}
	);
}


$(document).ready(
	function() {
		init_date_range();
		
		setup_daterangepicker();
		add_period_changing_trigger();
		
		setup_filters_dropdown_menu();
		setup_filters();
		
		setup_compare();
		
		setup_view_links();
		
		setup_limit_slider();
		
		setup_drill_down_links();
		setup_period_detail_links();
		
		// setup_graph_bar_animation(1000);
		
		setup_toggle_intern_log_pie_chart_links();
	}
);


function init_date_range() {
	var from = null;
	var to = null;
	
	try {
		var ranges = $("input#period").val().split(range_splitter);
		from = $.datepicker.parseDate(period_date_format, $.trim(ranges[0]), {shortYearCutoff: short_year_cutoff});
		to = $.datepicker.parseDate(period_date_format, $.trim(ranges[1]), {shortYearCutoff: short_year_cutoff});
	}
	catch(e) {
		from = null;
		to = null;
	}
	
	if(from == null || to == null) {
		from = Date.parse("today-30days");
		to = Date.parse("today");
	}
	
	$("input#date_range").val(
		[
			$.datepicker.formatDate(range_date_format, from),
			$.datepicker.formatDate(range_date_format, to)
		].join(" " + range_splitter + " ")
	);
}


function setup_daterangepicker() {
	if($("input#date_range").length <= 0) { return; }
	
	$("input#date_range").daterangepicker(
		{
			presetRanges: [
				{
					text: "最近的 7 天",
					dateStart: "today-6days",
					dateEnd: "today"
				},
				{
					text: "最近的 30 天",
					dateStart: "today-29days",
					dateEnd: "today"
				},
				{
					text: "本月 (月初到今天)",
					dateStart: function() {
						return Date.parse("today").moveToFirstDayOfMonth();
					},
					dateEnd: "today"
				},
				{
					text: "今年 (年初到今天)",
					dateStart: function() {
						var x= Date.parse("today");
						x.setMonth(0);
						x.setDate(1);
						return x;
					},
					dateEnd: "today"
				},
				{
					text: "上一个月",
					dateStart: function() {
						return Date.parse("1 month ago").moveToFirstDayOfMonth();
					},
					dateEnd: function() {
						return Date.parse("1 month ago").moveToLastDayOfMonth();
					}
				}
			],
			presets: {
				dateRange: "选择开始日期和结束日期"
			},
			rangeStartTitle: "开始日期",
			rangeEndTitle: "结束日期",
			doneButtonText: "确定",
			prevLinkText: "上一时段",
			nextLinkText: "下一时段",
			rangeSplitter: range_splitter,
			dateFormat: range_date_format,
			closeOnSelect: true,
			arrows: true,
			datepickerOptions: {
				showButtonPanel: false,
				showMonthAfterYear: true,
				shortYearCutoff: short_year_cutoff
			}
		}
	);
}


function add_period_changing_trigger() {
	$("button.btnDone").unbind("click", change_period).click(change_period);
	
	$(".ui-widget-content li").not($(".ui-widget-content li.ui-daterangepicker-dateRange"))
	.unbind("click", change_period).click(change_period);
	
	$("input#date_range").unbind("keyup").keyup(
		function(e) {
			if(e.keyCode == 13) {
				// ENTER key
				$(document).trigger("click");
				
				change_period();
			}
		}
	)
	.parent().find("a").unbind("click", change_period).click(change_period);
}


function setup_view_links() {
	$("a.view_link").unbind("click").click(
		function() {
			change_view($(this).attr("id").substr("view_link_".length));
			
			return false;
		}
	)
	.unbind("mouseenter mouseleave").hover(
		function() {
			var view = $(this).attr("id").substr("view_link_".length);
			var current_view = $("input#view").val();
			$(this).find("img").attr(
				"src",
				"/images/teachers/view_icons/" + view + "_view" +
				(view == current_view ? "_selected" : "_hover") +
				"_icon.gif"
			);
		},
		function() {
			var view = $(this).attr("id").substr("view_link_".length);
			var current_view = $("input#view").val();
			$(this).find("img").attr(
				"src",
				"/images/teachers/view_icons/" + view + "_view" +
				(view == current_view ? "_selected" : "") +
				"_icon.gif"
			);
		}
	);
}


function setup_limit_slider() {
	var current_limit = $("input#limit").val();
	$("#limit_slider_label").html(current_limit);
	
	if($("#limit_slider").length <= 0) { return; }
	
	$("#limit_slider").slider(
		{
			animate: true,
			min: 1,
			max: 100,
			range: "min",
			step: 1,
			slide: function(event, ui) {
				$("#limit_slider_label").html(ui.value);
			},
			stop: function(event, ui) {
				change_limit(ui.value);
			}
		}
	)
	.slider("value", current_limit);

	// create tick marks
	var slider_max = 100;
	var slider_width = 200;
	var tick_mark_num = 5;
	var tick_mark_width = slider_width/tick_mark_num;
	var tick_mark_value = slider_max/tick_mark_num;
	var label_width = 8; // used to make label text place at the center of tick mark
	for(var i=0; i<tick_mark_num; i++) {
		var tick_mark = '<div class="tick_mark"' +
						' style="left: ' + tick_mark_width*i + 'px;' +
						' width: ' + (tick_mark_width+(label_width/2)) + 'px;">' +
						(i < (tick_mark_num-1) ? tick_mark_value*(i+1) : '') +
						'</div>';
		$("#limit_slider").append(tick_mark);
	}
}


function setup_graph_bar_animation(duration) {
	$.each(
		$(".graph_bar"),
		function(i, bar) {
			var w = $(bar).css("width");
			$(bar).css("width", "0px");
			
			$(bar).animate(
				{
					width: w
				},
				duration
			);
		}
	);
}


function setup_period_detail_links() {
	var filters = get_filter_values();
	
	$.each(
		$("a[id^='period_detail_link_']"),
		function(i, link) {
			var extra_filters = get_extra_filters($(link).attr("id").substr("period_detail_link_".length));
			
			var params = $.extend(
				{
					period: $("input#period").val()
				},
				get_filter_values(),
				extra_filters || {}
			);
			$.each(
				["q", "v"],
				function(i, value) {
					if(value != $("#dataset_field").val()) {
						params[value] = "f"
					}
				}
			);
			
			var href = "/teachers/" + TEACHER_ID + "/statistics?" + $.param(params);
			
			$(link).attr("href", href);
		}
	);
}


function setup_drill_down_links() {
	var filters = get_filter_values();
	
	$.each(
		$("a[id^='drill_down_link_']"),
		function(i, link) {
			var drill_infos = $(link).attr("id").substr("drill_down_link_".length).split("_to_");
			
			var extra_filters = get_extra_filters(drill_infos[0]);
			
			var params = $.extend(
				{
					period: $("input#period").val()
				},
				get_filter_values(),
				extra_filters || {}
			);
			
			var href = "/teachers/" + TEACHER_ID + "/statistics/" + drill_infos[1] + "?" + $.param(params);
			
			$(link).attr("href", href);
		}
	);
}


function setup_compare() {
	$("a#compare_link").unbind("click").click(
		function(e) {
			$(this).datepicker(
				"dialog",
				$("input#compare").val(),
				function(date_text, inst) {
					change_compare(date_text);
				},
				{
					dateFormat: period_date_format,
					beforeShow: function(input) {
						// only for working around on IE6 ...
						// or we can just call $(input).hide();
						$(input).show();
						$(input).unbind("focus").focus(
							function() {
								$(this).hide();
							}
						);
						
						$(input).siblings(".ui-datepicker-dialog").css("z-index", 100);
					},
					showButtonPanel: false,
					showMonthAfterYear: true,
					shortYearCutoff: short_year_cutoff
				},
				e
			);
			
			return false;
		}
	);
	
	$("a#remove_compare_link").unbind("click").click(
		function() {
			change_compare("");
			
			return false;
		}
	);
}


function setup_filters_dropdown_menu() {
	APP.setup_dropdown_menu("#filters_link", 120, 350);
}


function setup_filters() {
	$.each(
		FILTERS,
		function(i, value) {
			$("a." + value + "_filter_link").unbind("click").click(
				function() {
					eval("filter_" + value)();

					return false;
				}
			);

			$("a#remove_" + value + "_filter_link").unbind("click").click(
				function() {
					change_filter(value, "");

					return false;
				}
			);
		}
	);
}


function get_filter_values() {
	var filters = {};
	
	$.each(
		FILTERS,
		function(i, value) {
			filters[value] = $("input#" + value).val()
		}
	);
	
	return filters;
}
