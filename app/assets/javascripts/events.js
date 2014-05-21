$(document).ready(function(){

	if(gon.edit_event){
		// load the date pickers
/*
		$('#event_start_date').datepicker({
				dateFormat: 'dd-mm-yy',
				timeFormat: 'hh:mm',
				separator: ' '
		});

		if (gon.start_date !== undefined &&
				gon.start_date.length > 0)
		{
			$('#event_start_date').datepicker("setDate", new Date(gon.start_date));
		}

		$('#event_end_date').datepicker({
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

    startDateTextBox.datepicker({ 
			dateFormat: 'yy-mm-dd',
			separator: ' ',
			changeMonth: true,
      changeYear: true,
      yearRange: "1700:2020",
	    onClose: function(dateText, inst) {
		    if (endDateTextBox.val() != '') {
			    var testStartDate = startDateTextBox.datepicker('getDate');
			    var testEndDate = endDateTextBox.datepicker('getDate');
			    if (testStartDate > testEndDate)
				    endDateTextBox.datepicker('setDate', testStartDate);
		    }
	    },
	    onSelect: function (selectedDateTime){
		    endDateTextBox.datepicker('option', 'minDate', startDateTextBox.datepicker('getDate') );
	    }
    });

		if (gon.start_date !== undefined &&
				gon.start_date.length > 0)
		{
			startDateTextBox.datepicker("setDate", new Date(gon.start_date));
		}

    endDateTextBox.datepicker({ 
			dateFormat: 'yy-mm-dd',
			separator: ' ',
			changeMonth: true,
      changeYear: true,
      yearRange: "1700:2020",
	    onClose: function(dateText, inst) {
		    if (startDateTextBox.val() != '') {
			    var testStartDate = startDateTextBox.datepicker('getDate');
			    var testEndDate = endDateTextBox.datepicker('getDate');
			    if (testStartDate > testEndDate)
				    startDateTextBox.datepicker('setDate', testEndDate);
		    }
	    },
	    onSelect: function (selectedDateTime){
		    startDateTextBox.datepicker('option', 'maxDate', endDateTextBox.datepicker('getDate') );
	    }
    });

		if (gon.end_date !== undefined &&
				gon.end_date.length > 0)
		{
			endDateTextBox.datepicker("setDate", new Date(gon.end_date));
		}


  }
});


