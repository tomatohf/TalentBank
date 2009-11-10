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
				
				// setup event handlers
				setup_corp_tag_links(resume_id);
				setup_corp_tag_input(resume_id);
			}
		}
	);
}


function setup_corp_tag_links(resume_id) {
	$("a[class^='corp_tag']").click(
		function() {
			var tags_input = $("#corp_resume_tags_input_" + resume_id);
			var tag = $(this).text();
			
			var current_tags = get_current_tags(resume_id, true);
			var new_tags = array_delete(current_tags, tag);
			
			if (current_tags.length == new_tags.length) {
				tags_input.val(tags_input.val() + tag + " ");
			}
			else {
				tags_input.val(new_tags.join(" "));
			}
			set_current_tags(resume_id, tags_input.val(), false);
			synchronize_tags_and_input(resume_id);
			
			return false;
		}
	);
}


function setup_corp_tag_input(resume_id, tags) {
	$("#corp_resume_tags_input_" + resume_id).keypress(
		function() {
			synchronize_tags_and_input(resume_id);
		}
	).val(get_current_tags(resume_id, false));
}


function get_current_tags(resume_id, as_array) {
	var tags = $("#corp_resume_tags_" + resume_id).val();
	if(as_array) {
		tags = tags.split(" ");
	}
	return tags;
}


function set_current_tags(resume_id, tags, as_array) {
	if(as_array) {
		tags = tags.join(" ");
	}
	$("#corp_resume_tags_" + resume_id).val(tags);
}


function array_include(array, item) {
	for(var i = 0; i < array.length; i++) {
		if(array[i] == item) {
			return true;
		}
	}
	
	return false;
}


function array_delete(array, item) {
	var new_array = [];
	
	for(var i = 0; i < array.length; i++) {
		if(array[i] != item) {
			new_array.push(array[i]);
		}
	}
	
	return new_array;
}


function synchronize_tags_and_input(resume_id) {
	var tags_container = $("#corp_tags_" + resume_id);
}


function save_resume_ok(data) {
	
}


function show_save_resume_dialog(content, button_text, ok_event) {
	DIALOG.appear(
		{
			title: "收藏简历",
			content: content,
			button_text: button_text,
			width: 530,
			margin_top: 100,
			fixed: false,
			data: {},
			modal: false,
			ok_event: ok_event
		}
	);
}
