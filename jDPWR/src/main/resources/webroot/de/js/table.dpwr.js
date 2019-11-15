
/*
 * Editor client script for DB table dpwr
 * Created by http://editor.datatables.net/generator
 */

(function($){

$(document).ready(function() {
	var editor = new $.fn.dataTable.Editor( {
		ajax: 'php/table.dpwr.php',
		table: '#dpwr',
		fields: [
			
		]
	} );

	var table = $('#dpwr').DataTable( {
		dom: 'Bfrtip',
		ajax: 'php/table.dpwr.php',
		columns: [
			
		],
		select: true,
		lengthChange: false,
		buttons: [
			{ extend: 'create', editor: editor },
			{ extend: 'edit',   editor: editor },
			{ extend: 'remove', editor: editor }
		]
	} );
} );

}(jQuery));

