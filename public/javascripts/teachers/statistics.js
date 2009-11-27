var range_date_format = "y年m月d日";
var range_splitter = "-";

var period_date_format = "yymmdd";


function view_detail(dot_index) {
	alert("view: " + dot_index);
}


function query_detail(dot_index) {
	alert("query: " + dot_index);
}


function change_view(view) {
	$("input#view").val(view);
	$("#refresh_form").submit();
}


function change_line(id, value) {
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


$(document).ready(
	function() {
		init_date_range();
		
		setup_daterangepicker();
		
		add_period_changing_trigger();
		
		setup_view_links();
	}
);


function init_date_range() {
	var from = null;
	var to = null;
	
	var ranges = PERIOD.split(range_splitter);
	try {
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
	$("a[class^='view_link_']").unbind("click").click(
		function() {
			change_view($(this).attr("class").substr("view_link_".length));
			
			return false;
		}
	)
	.unbind("mouseenter mouseleave").hover(
		function() {
			var view = $(this).attr("class").substr("view_link_".length);
			$(this).find("img").attr(
				"src",
				"/images/teachers/view_icons/" + view + "_view" +
				(VIEW == view ? "_selected" : "_hover") +
				"_icon.gif"
			);
		},
		function() {
			var view = $(this).attr("class").substr("view_link_".length);
			$(this).find("img").attr(
				"src",
				"/images/teachers/view_icons/" + view + "_view" +
				(VIEW == view ? "_selected" : "") +
				"_icon.gif"
			);
		}
	);
}
