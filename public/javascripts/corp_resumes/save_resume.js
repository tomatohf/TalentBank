function save_resume(resume_id) {
	show_save_resume_dialog(
		function(container) {
			save_resume_dialog_content(container, resume_id)
		},
		{
			ok: "收藏",
			cancel: "取消"
		},
		save_resume_ok
	);
}

function save_resume_dialog_content(container, resume_id) {
	container.html(
		'<img src="/images/loading_icon.gif" border="0" title="操作中" alt="操作中" style="margin: 0px 8px -3px 15px;" />' +
		'正在载入, 请稍候 ...'
	);
	
	$.ajax(
		{
			type: "GET",
			url: "/corporations/" + CORPORATION_ID + "/corp_saved_resumes/" + resume_id + "/edit",
			dataType: "html",
			data: {},
			error: function() {
				show_save_resume_dialog(
					'<p class="error_msg">载入失败, 再试一次吧</p>',
					{ cancel: "确定" },
					null
				);
			},
			success: function(data, text_status) {
				container.html(data);
			}
		}
	);
}

function save_resume_ok(data) {
	
}

function show_save_resume_dialog(content, button_text, ok_event) {
	DIALOG.appear(
		{
			title: "收藏简历",
			content: content,
			button_text: button_text,
			width: 400,
			margin_top: 100,
			fixed: false,
			data: {},
			modal: false,
			ok_event: ok_event
		}
	);
}
