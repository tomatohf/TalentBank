function view_detail() {
	
}


function query_detail() {
	alert();
}


function change_view(view) {
	$("#view").val(view);
	$("#counts_form").submit();
}


function setup_view_links() {
	$("a[class^='view_link_']").unbind("click").click(
		function() {
			change_view($(this).attr("class").substr("view_link_".length));
			
			return false;
		}
	)
	.unbind("mouseenter mouseleave").hover(
		function() {
			var view = $(this).attr("class").substr("view_link_".length);
			$(this).find("img").attr(
				"src",
				"/images/teachers/view_icons/" + view + "_view" +
				(VIEW == view ? "_selected" : "_hover") +
				"_icon.gif"
			);
		},
		function() {
			var view = $(this).attr("class").substr("view_link_".length);
			$(this).find("img").attr(
				"src",
				"/images/teachers/view_icons/" + view + "_view" +
				(VIEW == view ? "_selected" : "") +
				"_icon.gif"
			);
		}
	);
}


$(document).ready(
	function() {
		setup_view_links();
	}
);
