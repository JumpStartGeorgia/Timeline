var x;
$(document).ready(function() {

  if (gon.show_timeline){
	  x = createStoryJS({
		  type:		'timeline',
		  width:		'100%',
      lang:     I18n.locale,
		  height:		String($(window).height()-$('.navbar').height()),
		  source:		gon.json_data,
		  embed_id:	'timeline-embed',
      hash_bookmark: true,
      start_zoom_adjust: -1,
		  debug:		false
	  });
	  
	  // resize the timeline when the screen changes
    window.onresize = function()
    {
      $('#timeline-embed').css('height', String($(window).height()-$('.navbar').height()) + "px");
    }
	  
    // when the hash changes, 
    // - change the hash to use the id from the table record
    // - update the language switcher to also have this hash
    $(window).on('hashchange', function() {
      $('#language a').each(function(){
        url_ary = $(this).attr('href').split('#');
        $(this).attr('href', url_ary[0] + window.location.hash);
      });
    });

    // if url has hash and language link does not when page loads, add it
    if (window.location.hash.length > 0){
      $('#language a').each(function(){
        url_ary = $(this).attr('href').split('#');
        $(this).attr('href', url_ary[0] + window.location.hash);
      });
    }	  
  }

  if (gon.hidden_form){
    $('img#btn_submit').click(function() {
      $('form#event_form').submit();
    });

    $('form#event_form').submit(function() {
      $('#loading').fadeIn();

      // get the values
      var event, date, link, name, email;
      event = $('textarea[name="event"]').val();
      date = $('input[name="date"]').val();
      link = $('input[name="link"]').val();
      name = $('input[name="name"]').val();
      email = $('input[name="email"]').val();

      if (event === ''){
        // show required msg
        $('#loading').hide();
        $('#required_submit').fadeIn().delay(5000).fadeOut();
        $('textarea[name="event"]').focus();
      }else {
        // send email
        var dataString = "event="+event+"&date="+date+"&link="+link+"&name="+name+"&email="+email;
        var dataObj = new Object;
        dataObj.message = new Object;
        dataObj.message.event = event;
        dataObj.message.event_date = date;
        dataObj.message.url = link;
        dataObj.message.name = name;
        dataObj.message.email = email;

        $.ajax({
            type: "POST",
            url: gon.form_submission_path,
            data: dataObj,
            dataType:"json",
            timeout: 8000,
            error: function(response) {
              $('#loading').hide();
              if(response.status === "success") {
                // reset form fields
                $('form#event_form input').val('');
                $('form#event_form textarea').val('');

                // show success message
                $('#success_submit').fadeIn().delay(5000).fadeOut();
              } else{
                // show error message
                $('#error_submit').fadeIn().delay(5000).fadeOut();
              }
            },
            success: function(response) {
              $('#loading').hide();
              if(response.status === "success") {
                // reset form fields
                $('form#event_form input').val('');
                $('form#event_form textarea').val('');

                // show success message
                $('#success_submit').fadeIn().delay(5000).fadeOut();
              } else{
                // show error message
                $('#error_submit').fadeIn().delay(5000).fadeOut();
              }
            }
           });
      }
      return false;
    });

    $('img#img_slide_up').click(function() {
      this.src = ((this.src.indexOf('_up') === -1) ? '/assets/submit_event_' + I18n.locale + '_up.png' : '/assets/submit_event_' + I18n.locale + '.png');
      console.log(this);
      $('div#hidden_form').toggle('slow', function(){
      });
    });
  }
});
