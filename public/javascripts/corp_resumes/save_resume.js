function save_resume(resume_id) {
	show_save_resume_dialog(
		function(container) {
			save_resume_dialog_content(container, resume_id)
		},
		{
			ok: "保存",
			cancel: "取消"
		},
		resume_id,
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
			data: {
				current_tags: $("#corp_resume_tags_" + resume_id).val()
			},
			error: function() {
				show_save_resume_dialog(
					'<p class="error_msg">载入失败, 再试一次吧</p>',
					{ cancel: "确定" },
					null, null
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
	corp_tag_link_elements(resume_id).click(
		function() {
			var tag = $(this).text();
			
			var current_tags = get_current_tags(resume_id, true);
			var new_tags = array_delete(current_tags, tag);
			if (current_tags.length == new_tags.length) {
				new_tags.push(tag);
			}
			set_current_tags(resume_id, new_tags, true)
			synchronize_tags_and_input(resume_id);
			
			return false;
		}
	);
}


function setup_corp_tag_input(resume_id, tags) {
	$("#corp_resume_tags_input_" + resume_id).keyup(
		function() {
			synchronize_tags_and_input(resume_id);
		}
	);
	
	synchronize_tags_and_input(resume_id);
}


function corp_tag_link_elements(resume_id) {
	return $("#corp_tags_" + resume_id + " a[class^='corp_tag']");
}


function get_current_tags(resume_id, as_array) {
	var tags = $("#corp_resume_tags_input_" + resume_id).val();
	if(as_array) {
		tags = array_delete(tags.split(" "), "");
	}
	return tags;
}


function set_current_tags(resume_id, tags, as_array) {
	if(as_array) {
		tags = tags.join(" ");
	}
	$("#corp_resume_tags_input_" + resume_id).val(tags);
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
	var current_tags = get_current_tags(resume_id, true);
	
	$.each(
		corp_tag_link_elements(resume_id),
		function(i, ele) {
			var tag = $(ele).text();
			if($.inArray(tag, current_tags) < 0) {
				$(ele).attr("class", "corp_tag");
			}
			else {
				$(ele).attr("class", "corp_tag_selected");
			}
		}
	);
}


function save_resume_ok(data) {
	var resume_id = data.resume_id;
	do_save_resume(resume_id, get_current_tags(resume_id, false));
	
	return true;
}


function do_save_resume(resume_id, tags) {
	$.ajax(
		{
			type: "POST",
			url: "/corporations/" + CORPORATION_ID + "/corp_saved_resumes/" + resume_id,
			dataType: "html",
			data: {
				_method: "put", // simulate HTTP put request in rails
				tags: tags
			},
			error: function() {
				show_save_resume_dialog(
					'<p class="error_msg">保存失败, 再试一次吧</p>',
					{ cancel: "确定" },
					null, null
				);
			},
			success: function(data, text_status) {
				$("#save_resume_field_" + resume_id).html(data);
				
				setup_save_resume_links();
			}
		}
	);
}


function show_save_resume_dialog(content, button_text, resume_id, ok_event) {
	DIALOG.appear(
		{
			title: "收藏简历",
			content: content,
			button_text: button_text,
			width: 530,
			margin_top: 100,
			fixed: false,
			data: {
				resume_id: resume_id
			},
			modal: false,
			ok_event: ok_event
		}
	);
}


function setup_save_resume_links() {
	$("a[id^='save_resume_link_']").click(
		function() {
			save_resume($(this).attr("id").substr("save_resume_link_".length));
			
			return false;
		}
	);
}


$(document).ready(
	function() {
		setup_save_resume_links();
	}
);
