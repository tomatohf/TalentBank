/*
	require jquery.js
*/

var DIALOG = {
	
	disappear: function() {
		$("#dialog_overlay").animate(
			{
				opacity: 0
			},
			function() {
				$(this).hide();
			}
		);
		
		$("#dialog_window").animate(
			{
				opacity: 0
			},
			function() {
				$(this).hide();
			}
		);
    },
	
	appear: function(options) {
		var setting = $.extend(
			{
				data: {},
				margin_top: 100,
				button_text: { ok: "", cancel: "" },
				ok_event: function(data) { },
				cancel_event: function(data) { DIALOG.disappear(); },
				width: 400,
				fixed: true,
				title: "",
				content: "",
				modal: true,
				close: false,
				skin: "dialog_blue"
			},
			options
		);

		setting.docWidth = $(document).width();
		setting.docHeight = $(document).height();

		var dialog = $("#dialog_window");
		var overlay = $("#dialog_overlay");
		
		if (dialog.length == 0 || overlay.length == 0) {
			dialog.remove();
			overlay.remove();
			
			$(
				'<div id="dialog_overlay" class="dialog_overlay" />' +
				'<div id="dialog_window" class="dialog_blue dialog_position_absolute">' +
					'<table class="dialog_wrapper">' +
						'<tbody>' +
							'<tr>' +
								'<td class="dialog_top_left"></td>' +
								'<td class="dialog_border"></td>' +
								'<td class="dialog_top_right"></td>' +
							'</tr>' +
							'<tr>' +
								'<td class="dialog_border"></td>' +
								'<td class="dialog_content_container">' +
									'<div class="dialog_title_container">' +
										'<div class="dialog_title"></div>' +
										'<a href="#" class="dialog_close">关闭</a>' +
									'</div>' +
									'<div class="dialog_content" id="dialog_content"></div>' +
									'<div class="dialog_actions">' +
										'<input id="dialog_ok_btn" class="button" type="button" value="" />' +
										'<input id="dialog_cancel_btn" class="button" type="button" value="" />' +
									'</div>' +
								'</td>' +
								'<td class="dialog_border"></td>' +
							'</tr>' +
							'<tr>' +
								'<td class="dialog_bottom_left"></td>' +
								'<td class="dialog_border"></td>' +
								'<td class="dialog_bottom_right"></td>' +
							'</tr>' +
						'</tbody>' + 
					'</table>' +
				'</div>'
			).appendTo($(document.body));
			
			dialog = $("#dialog_window");
			overlay = $("#dialog_overlay");
        }

		overlay.css(
			{
				opacity: 0,
				display: "block"
			}
		);
		dialog.css(
			{
				opacity: 0,
				display: "block"
			}
		);


		dialog.attr("class", setting.skin + " " + (setting.fixed ? "dialog_position_fixed" : "dialog_position_absolute"));
		
		dialog.find(".dialog_title").html(setting.title);
		var ok_btn = dialog.find("#dialog_ok_btn");
		if(setting.button_text.ok && setting.button_text.ok != "") {
			ok_btn
				.val(setting.button_text.ok)
				.one(
					"click",
					function(e) {
						if(setting.ok_event(setting.data)) {
							DIALOG.disappear();
						}
					}
				)
				.show();
		}
		else {
			ok_btn.hide();
		}
		var cancel_btn = dialog.find("#dialog_cancel_btn")
		if(setting.button_text.cancel && setting.button_text.cancel != "") {
			cancel_btn
				.val(setting.button_text.cancel)
				.one(
					"click",
					function(e) {
						setting.cancel_event(setting.data);
					}
				)
				.show();
		}
		else {
			cancel_btn.hide();
		}
		var close_link = dialog.find("a.dialog_close");
		if(setting.close) {
			close_link.show();
			close_link.one("click", DIALOG.disappear);
		}
		else {
			close_link.hide();
		}

		if (typeof(setting.content) == "string") {
			$("#dialog_content").html(setting.content);
		}
		if (typeof(setting.content) == "function") {
			var e = $("#dialog_content");
			e.holder = dialog;
			setting.content(e);
		}
		
       
		if(setting.modal) {
			overlay.css(
				{
					height: setting.docHeight,
					opacity: 0
				}
			).animate(
				{
					opacity: 0.5
				}
			);
		}

        dialog.css(
			{
				width: setting.width,
				left: (setting.docWidth - setting.width) / 2,
				marginTop: setting.margin_top,
				top: document.documentElement.scrollTop
			}
		).animate(
			{
				opacity: 1
			},
			function() {
				$(this).css("opacity", "");
			}
		);
	}
	
}
