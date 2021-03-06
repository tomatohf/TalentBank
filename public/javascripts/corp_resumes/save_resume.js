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
			url: "/corporations/" + CORPORATION_ID + "/saved_resumes/" + resume_id + "/edit",
			dataType: "html",
			data: {
				current_tags: $("#corp_resume_tags_" + resume_id).val() || ""
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
	corp_tag_link_elements(resume_id).unbind("click").bind(
		"click",
		{
			resume_id: resume_id
		},
		corp_tag_link_handler
	);
}
function corp_tag_link_handler(event) {
	var resume_id = event.data.resume_id
	var tag = $(this).text();
	
	var current_tags = get_current_tags(resume_id, true);
	var new_tags = array_delete(current_tags, tag);
	if (current_tags.length == new_tags.length) {
		new_tags.push(tag);
	}
	set_current_tags(resume_id, new_tags, true);
	
	return false;
}


function setup_corp_tag_input(resume_id) {
	$("#corp_resume_tags_input_" + resume_id).unbind("keyup").bind(
		"keyup",
		{
			resume_id: resume_id
		},
		corp_tag_input_handler
	)
	.siblings("a").unbind("click").bind(
		"click",
		{
			resume_id: resume_id
		},
		clear_corp_tag_input_handler
	);
	
	synchronize_tags_and_input(resume_id);
}
function corp_tag_input_handler(event) {
	synchronize_tags_and_input(event.data.resume_id);
}
function clear_corp_tag_input_handler(event) {
	set_current_tags(event.data.resume_id, "", false);
	
	return false;
}


function corp_tag_link_elements(resume_id) {
	return $("#corp_tags_" + resume_id + " a[class^='corp_tag']");
}


function get_current_tags(resume_id, as_array) {
	var tags = $("#corp_resume_tags_input_" + resume_id).val() || "";
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
	
	synchronize_tags_and_input(resume_id);
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
			url: "/corporations/" + CORPORATION_ID + "/saved_resumes/" + resume_id,
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


function remove_saved_resume(resume_id) {
	if(confirm("确定要删除这份简历的所有标签么 ?")) {
		do_save_resume(resume_id, "");
	}
}


function show_save_resume_dialog(content, button_text, resume_id, ok_event) {
	DIALOG.appear(
		{
			title: "简历标签",
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
	$("a[id^='save_resume_link_']").unbind("click").click(
		function() {
			save_resume($(this).attr("id").substr("save_resume_link_".length));

			return false;
		}
	);
	
	$("a[id^='remove_saved_resume_link_']").unbind("click").click(
		function() {
			remove_saved_resume($(this).attr("id").substr("remove_saved_resume_link_".length));

			return false;
		}
	);
}


function setup_edit_resume_tags_links() {
	$("a[id^='edit_resume_tags_link_']").unbind("click").click(
		function() {
			save_resume($(this).attr("id").substr("edit_resume_tags_link_".length));

			return false;
		}
	);
}


$(document).ready(
	function() {
		setup_save_resume_links();
		
		
		setup_update_tag_links();
		setup_destroy_tag_links();
		
		
		setup_edit_resume_tags_links();
	}
);


function setup_update_tag_links() {
	$("a.update_tag_link").unbind("click").click(
		function() {
			update_tag($.trim(TAG_NAME));
			
			return false;
		}
	);
}

function setup_destroy_tag_links() {
	$("a.destroy_tag_link").unbind("click").click(
		function() {
			var tag_name = $.trim(TAG_NAME);
			
			if(confirm("确定要删除所有 " + tag_name + " 的标签么 ?")) {
				$("#destroy_tag_name").val(tag_name);
				$("#destroy_tag_form").submit();
			}
			
			return false;
		}
	);
}

function show_update_tag_dialog(content, button_text, ok_event) {
	DIALOG.appear(
		{
			title: "修改标签名称",
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

function update_tag(old_tag_name) {
	var content = 	'<label for="update_tag_field" style="margin-right: 10px;">' + 
						required_mark + ' 新标签名称:' +
					'</label>' +
					'<input type="text" id="update_tag_field" name="update_tag_field" class="text_field" size="30" value="' + 
						old_tag_name + '" />' +
					'';
					
	show_update_tag_dialog(
		content,
		{ ok: "保存", cancel: "取消" },
		function(data) {
			var new_tag_name = $("#update_tag_field").val();
			
			if(new_tag_name != null && new_tag_name != "" && new_tag_name != old_tag_name) {
				do_update_tag(old_tag_name, new_tag_name);
			}
			
			return true;
		}
	);
}

function do_update_tag(old_tag_name, new_tag_name) {
	$("#old_tag_name").val(old_tag_name);
	$("#new_tag_name").val(new_tag_name);
	$("#update_tag_form").submit();
}
