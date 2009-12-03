var range_date_format = "y年m月d日";
var range_splitter = "-";

var period_date_format = "yymmdd";

var FILTERS = ["level", "graduation", "college", "major", "student", "corp"];


function view_detail(dot_index) {
	show_details("view", $("input#dot_" + dot_index).val());
}


function query_detail(dot_index) {
	show_details("query", $("input#dot_" + dot_index).val());
}


function compared_view_detail(dot_index) {
	show_details("view", $("input#compared_dot_" + dot_index).val());
}


function compared_query_detail(dot_index) {
	show_details("query", $("input#compared_dot_" + dot_index).val());
}


function show_details(detail_type, detail_period) {
	show_details_dialog(
		function(container) {
			show_details_dialog_content(container, null, detail_type, detail_period);
		}
	);
}


function show_details_dialog_content(container, url, detail_type, detail_period) {
	if(url == null) {
		container.html(
			'<img src="/images/loading_icon.gif" border="0" title="操作中" alt="操作中" style="margin: 0px 8px -3px 15px;" />' +
			'正在载入, 请稍候 ...'
		);
	}
	
	var data = {
		type: detail_type,
		period: detail_period
	};
	$.each(
		FILTERS,
		function(i, value) {
			data[value] = $("input#" + value).val()
		}
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
				
				setup_details_dialog_links(container, detail_type, detail_period);
			}
		}
	);
}


function setup_details_dialog_links(container, detail_type, detail_period) {
	$(".pagination a").unbind("click").click(
		function() {
			show_details_dialog_content(container, $(this).attr("href"), detail_type, detail_period);
			
			return false;
		}
	);
	
	
	$(".operation_link").unbind("click").click(
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
			from = $.datepicker.parseDate(range_date_format, $.trim(ranges[0]));
			to = $.datepicker.parseDate(range_date_format, $.trim(ranges[1]));
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
	show_filter_dialog(
		function(container) {
			var links = $.map(
				LEVELS,
				function(level_obj, i) {
					return '<a href="#" id="filter_level_' + level_obj.id + '" class="filter_item_link">' +
								level_obj.name +
							'</a>';
				}
			);

			container.html(links.join(""));
			
			setup_filter_links(container);
		},
		"过滤教育水平"
	);
}


function filter_graduation() {
	show_filter_dialog(
		function(container) {
			var links = $.map(
				GRADUATIONS,
				function(graduation_obj, i) {
					return '<a href="#" id="filter_graduation_' + graduation_obj.id + '" class="filter_item_link">' +
								graduation_obj.name +
							'</a>';
				}
			);

			container.html(links.join(""));
			
			setup_filter_links(container);
		},
		"过滤毕业时间"
	);
}


function filter_college() {
	show_filter_dialog(
		function(container) {
			var links = $.map(
				COLLEGES,
				function(college_obj, i) {
					return '<a href="#" id="filter_college_' + college_obj.id + '" class="filter_item_link">' +
								college_obj.name +
							'</a>';
				}
			);

			container.html(links.join(""));
			
			setup_filter_links(container);
		},
		"过滤学院"
	);
}


function filter_major() {
	show_filter_dialog(
		function(container) {
			var major_objs = MAJORS["c_" + $("input#college").val()];
			if(major_objs != null && major_objs.length > 0) {
				var links = $.map(
					major_objs,
					function(major_obj, i) {
						return '<a href="#" id="filter_major_' + major_obj.id + '" class="filter_item_link">' +
									major_obj.name +
								'</a>';
					}
				);

				container.html(links.join(""));

				setup_filter_links(container);
			}
		},
		"过滤专业"
	);
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
			data: {},
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


function setup_filter_links(container) {
	container.find("a[id^='filter_']").unbind("click").click(
		function() {
			var filter = $(this).attr("id").substr("filter_".length).split("_");
			change_filter(filter[0], filter[1]);
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


$(document).ready(
	function() {
		init_date_range();
		
		setup_daterangepicker();
		add_period_changing_trigger();
		
		setup_filters();
		
		setup_compare();
		
		setup_view_links();
	}
);


function init_date_range() {
	var from = null;
	var to = null;
	
	try {
		var ranges = $("input#period").val().split(range_splitter);
		from = $.datepicker.parseDate(period_date_format, $.trim(ranges[0]));
		to = $.datepicker.parseDate(period_date_format, $.trim(ranges[1]));
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
				showMonthAfterYear: true
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
	$("a[id^='view_link_']").unbind("click").click(
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
						$(input).hide();
					},
					showButtonPanel: false,
					showMonthAfterYear: true
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


function setup_filters() {
	$.each(
		FILTERS,
		function(i, value) {
			$("a#" + value + "_filter_link").unbind("click").click(
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
