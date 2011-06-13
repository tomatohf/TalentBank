function build_table(info) {
	var table = $('<table border="1"></table>');
	$.each(
		info,
		function(key, value) {
			table.append(
				$('<tr></tr>')
					.append(
						$('<td></td>').text(key)
					)
					.append(
						$('<td></td>').text(value)
					)
			);
		}
	);
	return table;
}


function import_students() {
	var container = $("#students_import"),
		students_data = container.find("textarea#students").val();
	
	container.html(
		$('<div class="importing"></div>')
			.append(
				'<img src="/images/loading_icon.gif" border="0" />'
			)
			.append(
				"正在导入，操作可能耗时较长，请耐心等待 ... 导入结束后，将显示结果及完成情况"
			)
	);
	$.ajax(
		{
			timeout: 1 * 24 * 60 * 60 * 1000, // very long time => 1 day
			type: "POST",
			url: "",
			dataType: "json",
			data: {
				students: students_data
			},
			error: function(jq_xhr, text_status, error_thrown) {
				container
					.before(
						$('<p class="error_msg"></p>').html(
							"导入过程中发生错误，导入程序没有成功结束。请保存如下出错信息，并联系技术人员"
						)
					)
					.html(
						build_table(
							{
								textStatus: text_status,
								errorThrown: error_thrown + "",
								data: students_data
							}
						)
					);
			},
			success: function(data) {
				if(data.finished) {
					var saved_count = data.saved_count,
						failed = data.failed,
						failed_count = failed.length;
					
					if(failed_count > 0) {
						container.html("")
							.before(
								$('<p class="warn_msg"></p>').html(
									"导入程序已执行完毕：共解析出 " + (saved_count + failed_count) + " 名学生的数据，" +
									"其中的 " + saved_count + " 名已经成功导入"
								)
							)
							.before(
								$('<p class="error_msg"></p>').html(
									"共有 " + failed_count + " 名学生导入失败，数据如下："
								)
							)
							.html(
								$('<textarea></textarea>')
									.attr(
										{
											class: "text_field",
											readonly: "true"
										}
									)
									.unbind("click").click(
										function() {
											$(this).select();
										}
									)
									.val("[" + failed.join("\n,\n") + "]")
							);
					}
					else {
						container.html("").before(
							$('<p class="success_msg"></p>').html(
								"导入程序已成功执行，共导入 " + saved_count + " 名学生"
							)
						);
					}
				}
				else {
					container.html("").before(
						$('<p class="error_msg"></p>').html(
							"导入程序没有成功执行： " + data.message
						)
					);
				}
			}
		}
	);
}


$(document).ready(
	function() {
		$("#students_import #begin_import").unbind("click").click(
			function() {
				if(confirm("确定要导入么 ?")) {
					import_students();
				}
				
				return false;
			}
		);
	}
);
