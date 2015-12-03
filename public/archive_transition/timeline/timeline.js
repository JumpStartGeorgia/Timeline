var timeline_data;

function generate_timeline(){
  if (!$.isEmptyObject(gon.json_data)){
    createStoryJS({
	    type:		'timeline',
	    width:		'100%',
      lang:     I18n.locale,
	    height:		String($(window).height()-$('.js-get-footer-height').height()),
	    source:		timeline_data,
	    embed_id:	'timeline-embed',
      hash_unique_bookmark: true,
      start_zoom_adjust: -1,
	    debug:		false,
	    start_at_end: true
    });
  }
}

// reload the timeline with all data
function reload_timeline(){
  timeline_data = JSON.parse(JSON.stringify(gon.json_data));
  $(global).unbind();
  $('#timeline-embed').html('');
  generate_timeline();
  window.location.hash = "_";
}

$(document).ready(function() {

  window.onresize = function() {
    $('#timeline-embed').css('height', String($(window).height()-$('.js-get-footer-height').height()) + "px");
  }

	// clone the json data so searching can search through the original
  timeline_data = JSON.parse(JSON.stringify(gon.json_data));

  generate_timeline();

});
