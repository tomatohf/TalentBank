function setup_dropdown_menu(selector, width, max_height) {
	if(width == null) {
		width = 150;
	}
	if(max_height == null) {
		max_height = 300;
	}
	
	$(selector).unbind("click").click(
		function() {
			$(this).parent().find("ul.dropdown_sub_menu")
				.css(
					{
						width: width + "px",
						maxHeight: max_height + "px"
					}
				)
				.slideDown(
					"fast",
					function() {
						var  menu = $(this).parent().find("ul.dropdown_sub_menu");
						menu.css(
							"height",
							(menu[0].scrollHeight > max_height) ? (max_height+"px") : "auto"
						);
					}
				).show();

			$(this).parent().unbind("mouseenter mouseleave").hover(
				function() {
				},
				function() {
					$(this).parent().find("ul.dropdown_sub_menu").slideUp("slow");
				}
			);
			
			return false;
		}
	);
}
