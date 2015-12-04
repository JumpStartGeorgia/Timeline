function generate_timeline(timeline_data){
  if (!$.isEmptyObject(timeline_data)){
    createStoryJS({
	    type:		'timeline',
	    width:		'100%',
      lang:     'ka',
	    height:		String($(window).height()-$('.js-get-footer-height').height()),
	    source:		timeline_data,
	    embed_id:	'timeline-embed',
      hash_unique_bookmark: true,
      start_zoom_adjust: -1,
	    debug:		false,
	    start_at_end: true
    });
  }

  window.onresize = function() {
    $('#timeline-embed').css('height', String($(window).height()-$('.js-get-footer-height').height()) + "px");
  }
}

function load_timeline() {
  $.getJSON(
    'http://localhost:3000/ka/timeline_events.json',
    function(data) {
      generate_timeline(data)
    }
  );
}

$(document).ready(function() {
  load_timeline();
});
