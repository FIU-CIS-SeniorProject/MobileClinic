# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
	$('#datatable_3').dataTable({
	"iDisplayLength": 10,
	"sPaginationType": "full_numbers"
				});
