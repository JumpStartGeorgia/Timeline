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
  return 'http://localhost:3000/' + timeline_language() + '/timeline_events.json';
}

function load_timeline() {
  $.getJSON(
    timeline_events_json_url(),
    function(data) {
      generate_timeline(data);
    }
  );
}

$(document).ready(function() {
  load_timeline();
});
