function save_resume() {
	if(!DIALOG.appeared()) {
		show_save_resume_dialog(
			save_resume_dialog_content,
			{
				ok: "收藏",
				cancel: "取消"
			},
			save_resume_ok
		);
	}
}

function save_resume_dialog_content(container) {
	container.html(
		'<img src="/images/loading_icon.gif" border="0" title="操作中" alt="操作中" style="margin: 0px 8px -3px 15px;" />' +
		'正在载入, 请稍候 ...'
	);
	
	// container.html('<div style="height: 200px;">aaa</div>');
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


$(document).ready(
	function() {
		$("#save_resume_link").click(
			function() {
				save_resume();
			}
		);
	}
);
