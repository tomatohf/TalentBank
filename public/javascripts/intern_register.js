$("#industry_category_wish").unbind("change").change(
	function() {
		APP.fill_industries("#industry_wish", $(this).val(), "", "选择行业细分");
	}
);
$("#job_category_class_wish").unbind("change").change(
	function() {
		APP.fill_job_categories("#job_category_wish", $(this).val(), "", "选择岗位细分");
	}
);

$("select.aspect").unbind("change").change(
	function() {
		var aspect_select = $(this);
		$.each(
			aspect_select.find("option"),
			function(i, option) {
				aspect_select.siblings("." + $(option).val()).hide();
			}
		);
		aspect_select.siblings("." + aspect_select.val()).show().find(":input:first").focus();
	}
).change();

(
	function() {
		var interval = null,
			content = $("#university").val();
		$("#university").autocomplete(
			{
				delay: 100,
				minLength: 0,
				source: UNIVERSITY_NAMES,
				open: function() {
					var minHeight = 300,
						popup = $(".ui-autocomplete").removeClass("ui-corner-all");

					popup.css(
						{
							height: "auto",
							overflow: "auto"
						}
					);

					if(popup.outerHeight() > minHeight) {
						popup.css(
							{
								height: minHeight + "px"
							}
						);
					}
					else {
						popup.css(
							{
								height: "auto"
							}
						);
					}
				},
				focus: function() {
					return false;
				},
				select: function(event, ui) {
					content = ui.item.label;
				}
			}
		).focus(
			function() {
				window.clearInterval(interval);
				interval = window.setInterval(
					function() {
						var newContent = $("#university").val();
						if(newContent != content) {
							content = newContent;
							$("#university").autocomplete("search");
						}
					},
					300
				);
			}
		).blur(
			function() {
				window.clearInterval(interval);
			}
		);
	}()
);

$("a.add_wish_link").unbind("click").click(
	function() {
		var aspect_select = $("select.aspect"),
			wish_fields = aspect_select.siblings("." + aspect_select.val());
		
		return false;
	}
);

$("#name").focus();
