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
				button_text: { ok: "确定", cancel: "取消" },
				ok_event: function(data, args) { },
				width: 400,
				fixed: true,
				title: "",
				content: "",
				modal: true,
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
				'<div class="dialog_blue" id="dialog_window">' +
					'<div class="dialog_top">' +
						'<div class="dialog_top_left dialog_png_fiexed">&nbsp;</div>' +
						'<div class="dialog_border_top dialog_png_fiexed">&nbsp;</div>' +
						'<div class="dialog_top_right dialog_png_fiexed">&nbsp;</div>' +
					'</div>' +
					'<div class="dialog_middle">' +
						'<div class="dialog_border_left dialog_png_fiexed">&nbsp;</div>' +
						'<div class="dialog_middle_content">' +
							'<div class="dialog_title" />' +
							'<div class="dialog_content" id="dialog_container_content" />' +
							'<div class="dialog_actions">' +
								'<input id="dialog_ok_btn" type="button" value="" />' +
								'&nbsp;&nbsp;' +
								'<input id="dialog_cancel_btn" type="button" value="" />' +
							'</div>' +
						'</div>' +
						'<div class="dialog_border_right dialog_png_fiexed">&nbsp;</div>' +
					'</div>' +
					'<div class="dialog_bottom">' +
						'<div class="dialog_bottom_left dialog_png_fiexed">&nbsp;</div>' +
						'<div class="dialog_border_bottom dialog_png_fiexed">&nbsp;</div>' +
						'<div class="dialog_bottom_right dialog_png_fiexed">&nbsp;</div>' +
					'</div>' +
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


		dialog.attr("class", setting.skin);
		
		dialog.find(".dialog_title").html(setting.title);
		dialog.find("#dialog_ok_btn")
				.val(setting.button_text.ok)
				.one(
					"click",
					function(e) {
						if(setting.ok_event(setting.data)) {
							DIALOG.disappear();
						}
					}
				);
		dialog.find("#dialog_cancel_btn")
				.val(setting.button_text.cancel)
				.one("click", DIALOG.disappear);

		if (typeof(setting.content) == "string") {
			$("#dialog_container_content").html(setting.content);
		}
		if (typeof(setting.content) == "function") {
			var e = $("#jdialog_container_content");
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
				position: (setting.fixed ? "fixed" : "absolute"),
				width: setting.width,
				left: (setting.docWidth - setting.width) / 2,
				top: (setting.margin_top + document.documentElement.scrollTop)
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
