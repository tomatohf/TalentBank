function allow_corporation_query(corp_id) {
	var url = "/teachers/" + TEACHER_ID + "/allow_corporation_query";
	adjust_corporation_query(url, corp_id);
}

function inhibit_corporation_query(corp_id) {
	var url = "/teachers/" + TEACHER_ID + "/inhibit_corporation_query";
	adjust_corporation_query(url, corp_id);
}

function adjust_corporation_query(url, corp_id) {
	show_query_loading();
	
	$.ajax(
		{
			type: "POST",
			url: url,
			dataType: "html",
			data: {
				corporation_id: corp_id
			},
			complete: hide_query_loading,
			success: function(data, text_status) {
				$("#allow_query_field_" + corp_id).replaceWith(data);
				
				setup_dropdown_menus();
			}
		}
	);
}


function show_query_loading() {
	$("#query_loading").css("visibility", "visible");
}

function hide_query_loading() {
	$("#query_loading").css("visibility", "hidden");
}


function setup_dropdown_menus() {
	APP.setup_dropdown_menu(".operation_link", 130);
	APP.setup_dropdown_menu(".statistics_link", 120);
}


$(document).ready(
	function() {
		setup_dropdown_menus();
	}
);
