function timeline_language() {
  return $('html').prop('lang');
}

function timeline_height() {
  return $(window).height();
}

function generate_timeline(timeline_data) {
  if (!$.isEmptyObject(timeline_data)) {
    createStoryJS({
	    type:		'timeline',
	    width:		'100%',
      lang:     timeline_language(),
	    height:		String(timeline_height()),
	    source:		timeline_data,
	    embed_id:	'timeline-embed',
      hash_unique_bookmark: true,
      start_zoom_adjust: -1,
	    debug:		false,
	    start_at_end: true
    });
  }

  window.onresize = function() {
    $('#timeline-embed').css('height', String(timeline_height() + "px"));
  }
}

function timeline_events_json_url() {
  return 'http://gudiashvili.jumpstart.ge/'+ timeline_language() + '/timeline_events.json';
}

function load_timeline() {
  $.ajax({

    url: timeline_events_json_url(),

    // The name of the callback parameter, as specified by the YQL service
    jsonp: "callback",

    // Tell jQuery we're expecting JSONP
    dataType: "jsonp",

    // Work with the response
    success: function(response) {
      generate_timeline(response);
    }

  });
}

$(document).ready(function() {
  load_timeline();
});
