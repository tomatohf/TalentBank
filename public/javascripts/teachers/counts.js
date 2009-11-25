function view_detail(dot_index) {
	alert(dot_index);
}


function query_detail(dot_index) {
	alert(dot_index);
}


function change_period() {
	// check whether changed ... to avoid refresh with same values
	alert($("#date_range").val());
}


function change_view(view) {
	$("#view").val(view);
	$("#counts_form").submit();
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


function setup_datepickers() {
	$("input#date_range").daterangepicker(
		{
			presetRanges: [
				{
					text: "最近的 7 天",
					dateStart: "today-7days",
					dateEnd: "today"
				},
				{
					text: "最近的 30 天",
					dateStart: "today-30days",
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
			rangeSplitter: "-",
			dateFormat: "y年m月d日",
			closeOnSelect: false,
			arrows: true,
			datepickerOptions: {
				showButtonPanel: false,
				showMonthAfterYear: true
			}
		}
	);
	
	
	$("#date_range").parent().find("a").unbind("click", change_period).click(change_period);
	
	// select date range
	// select one date and click outside
	// click quick menu item
	// input edit directly
}


function adjust_font_size() {
	$("body").append(
		$(
			'<style>' +
				'.ui-datepicker, .ui-datepicker table thead {' +
					'font-size: 12px;' +
				'}' +
				'.ui-datepicker table tbody {' +
					'font-size: 10px;' +
				'}' +
				'.ui-widget, .ui-widget input {' +
					'font-size: 12px;' +
				'}' +
				
				'.ui-daterangepicker button.btnDone, .ui-daterangepicker .title-start {' +
					'font-size: 12px;' +
				'}' +
				'.ui-daterangepicker .title-end, .ui-daterangepicker .ui-datepicker-inline {' +
					'font-size: 12px;' +
				'}' +
				'.ui-daterangepicker .ranges {' +
					'padding-bottom: 30px;' +
				'}' +
				'.ui-daterangepicker-arrows {' +
					'width: ' + (204 + 20) + 'px;' +
				'}' +
				'.ui-daterangepicker-arrows input.ui-rangepicker-input {' +
					'width: ' + (158 + 20) + 'px;' +
				'}' +
			'</style>'
		)
	);
}


$(document).ready(
	function() {
		setup_view_links();
		
		adjust_font_size();
		setup_datepickers();
	}
);
