$(document).ready(function(){

	if(gon.edit_event){
		// load the date pickers
/*
		$('#event_start_date').datetimepicker({
				dateFormat: 'dd-mm-yy',
				timeFormat: 'hh:mm',
				separator: ' '
		});

		if (gon.start_date !== undefined &&
				gon.start_date.length > 0)
		{
			$('#event_start_date').datepicker("setDate", new Date(gon.start_date));
		}

		$('#event_end_date').datetimepicker({
				dateFormat: 'dd-mm-yy',
				timeFormat: 'hh:mm',
				separator: ' '
		});

		if (gon.end_date !== undefined &&
				gon.end_date.length > 0)
		{
			$('#event_end_date').datepicker("setDate", new Date(gon.end_date));
		}

*/
    var startDateTextBox = $('#event_start_date');
    var endDateTextBox = $('#event_end_date');

    startDateTextBox.datetimepicker({ 
			dateFormat: 'dd-mm-yy',
			timeFormat: 'hh:mm',
			separator: ' ',
	    onClose: function(dateText, inst) {
		    if (endDateTextBox.val() != '') {
			    var testStartDate = startDateTextBox.datetimepicker('getDate');
			    var testEndDate = endDateTextBox.datetimepicker('getDate');
			    if (testStartDate > testEndDate)
				    endDateTextBox.datetimepicker('setDate', testStartDate);
		    }
	    },
	    onSelect: function (selectedDateTime){
		    endDateTextBox.datetimepicker('option', 'minDate', startDateTextBox.datetimepicker('getDate') );
	    }
    });

		if (gon.start_date !== undefined &&
				gon.start_date.length > 0)
		{
			startDateTextBox.datepicker("setDate", new Date(gon.start_date));
		}

    endDateTextBox.datetimepicker({ 
			dateFormat: 'dd-mm-yy',
			timeFormat: 'hh:mm',
			separator: ' ',
	    onClose: function(dateText, inst) {
		    if (startDateTextBox.val() != '') {
			    var testStartDate = startDateTextBox.datetimepicker('getDate');
			    var testEndDate = endDateTextBox.datetimepicker('getDate');
			    if (testStartDate > testEndDate)
				    startDateTextBox.datetimepicker('setDate', testEndDate);
		    }
	    },
	    onSelect: function (selectedDateTime){
		    startDateTextBox.datetimepicker('option', 'maxDate', endDateTextBox.datetimepicker('getDate') );
	    }
    });

		if (gon.end_date !== undefined &&
				gon.end_date.length > 0)
		{
			endDateTextBox.datepicker("setDate", new Date(gon.end_date));
		}


  }
});


