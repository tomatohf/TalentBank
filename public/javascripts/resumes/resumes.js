function fill_domains(category_id) {
	$("#domain_id").html("");

	var domain_objs = DOMAINS["c_" + category_id];
	if(domain_objs != null && domain_objs.length > 0) {
		var options = $.map(
			domain_objs,
			function(domain_obj, i) {
				return "<option value='" + domain_obj.id + "'>" + domain_obj.name + "</option>";
			}
		);

		$("#domain_id").append(options.join(""));
	}
}


function copy_resume(from_resume_id, to_resume_id, from_domain_name, to_domain_name) {
	if(confirm("确定要将 " + from_domain_name + " 的简历内容复制到 " + to_domain_name + " 的简历么 ? " + to_domain_name + " 的简历中的现有内容将被全部清除 !")) {
		$("#copy_to_resume_id").val(to_resume_id);
		$("#copy_resume_form")
			.attr("action", "/students/" + STUDENT_ID + "/resumes/" + from_resume_id + "/copy")
			.submit();
	}
}


function del_resume(resume_id, domain) {
	if(confirm("确定要将 " + domain + " 的简历放入回收站么 ?")) {
		$("#del_resume_form")
			.attr("action", "/students/" + STUDENT_ID + "/resumes/" + resume_id)
			.submit();
	}
}


function restore_resume(resume_id, domain) {
	if(confirm("确定要将 " + domain + " 的简历从回收站中还原么 ?")) {
		$("#restore_resume_form")
			.attr("action", "/students/" + STUDENT_ID + "/resumes/" + resume_id + "/restore")
			.submit();
	}
}


function update_resume(resume_id, domain, online) {
	var msg = online ? "确定要将 " + domain + " 的简历上线么 ?" : "确定要将 " + domain + " 的简历下线么 ? 下线后该简历将无法被企业检索和浏览";
	if(confirm(msg)) {
		$("#online").val(online.toString());
		$("#update_resume_form")
			.attr("action", "/students/" + STUDENT_ID + "/resumes/" + resume_id)
			.submit();
	}
}


function setup_domain_select() {
	$("#domain_category").unbind("change").change(
		function() {
			fill_domains($(this).val());
		}
	);
}


function setup_resume_mouse_over() {
	$(".resume_row, .trash_resume_row").unbind("mouseenter mouseleave").hover(
		function() {
			$(this).css("backgroundColor", "#F1F6F9");
		},
		function() {
			$(this).css("backgroundColor", "#FFFFFF");
		}
	);
}


function setup_trash_visible_ibutton() {
	var cookie_name = "trash_visible";
	var checked = ($.cookie(cookie_name) == "1");
	
	if(checked) {
		$("#trash_visible").attr("checked", true);
		
		show_trash_resume(false);
	}
	else {
		$("#trash_visible").attr("checked", false);
		
		hide_trash_resume(false);
	}
	
	
	$("#trash_visible").iButton(
		{
			labelOn: "显示",
			labelOff: "隐藏",
			change: function(checkbox) {
				var checked = checkbox.is(":checked")
				if(checked) {
					show_trash_resume(true);
				}
				else {
					hide_trash_resume(true);
				}
				
				// store the value in cookie
				var date = new Date();
				// 1 year(365 days) later
				date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000));
				$.cookie(cookie_name, checked ? 1 : 0, { expires: date });
			}
		}
	);
	
	$("div.ibutton-label-on span").css(
		{
			"padding-left": 12
		}
	);
	$("div.ibutton-label-off span").css(
		{
			"padding-right": 12
		}
	);
	
	$("#trash_visible").iButton("toggle", checked);
}


function show_trash_resume(animation) {
	$(".trash_section_title").show();
	
	$(".trash_resume_row").show();
	
	if(animation) {
		$(".trash_resume_row").find("td div").hide().slideDown("fast");
	}
}


function hide_trash_resume(animation) {
	if(animation) {
		$(".trash_resume_row").find("td div").slideUp(
			"fast",
			function() {
				$(".trash_resume_row").hide();
				
				$(".trash_section_title").hide();
			}
		);
	}
	else {
		$(".trash_resume_row").hide();
		
		$(".trash_section_title").hide();
	}
}


$(document).ready(
	function() {
		setup_trash_visible_ibutton();
		
		APP.setup_dropdown_menu(".edit_link", 110);
		APP.setup_dropdown_menu(".copy_link", 130);
		
		setup_domain_select();
		
		setup_resume_mouse_over();
		
		
		// make success msg disappear some time later
		$(".success_msg").animate(
			{
				opacity: 90
			},
			5000,
			function() {
				$(".success_msg").animate(
					{
						opacity: 0
					},
					3000,
					function() {
						$(this).remove();
					}
				);
			}
		);
	}
);



// jquery cookie plugin
jQuery.cookie = function(name, value, options) {
    if (typeof value != 'undefined') { // name and value given, set cookie
        options = options || {};
        if (value === null) {
            value = '';
            options.expires = -1;
        }
        var expires = '';
        if (options.expires && (typeof options.expires == 'number' || options.expires.toUTCString)) {
            var date;
            if (typeof options.expires == 'number') {
                date = new Date();
                date.setTime(date.getTime() + (options.expires * 24 * 60 * 60 * 1000));
            } else {
                date = options.expires;
            }
            expires = '; expires=' + date.toUTCString(); // use expires attribute, max-age is not supported by IE
        }
        // CAUTION: Needed to parenthesize options.path and options.domain
        // in the following expressions, otherwise they evaluate to undefined
        // in the packed version for some reason...
        var path = options.path ? '; path=' + (options.path) : '';
        var domain = options.domain ? '; domain=' + (options.domain) : '';
        var secure = options.secure ? '; secure' : '';
        document.cookie = [name, '=', encodeURIComponent(value), expires, path, domain, secure].join('');
    } else { // only name given, get cookie
        var cookieValue = null;
        if (document.cookie && document.cookie != '') {
            var cookies = document.cookie.split(';');
            for (var i = 0; i < cookies.length; i++) {
                var cookie = jQuery.trim(cookies[i]);
                // Does this cookie string begin with the name we want?
                if (cookie.substring(0, name.length + 1) == (name + '=')) {
                    cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                    break;
                }
            }
        }
        return cookieValue;
    }
};
