$(document).ready(function() {

  if (gon.show_timeline){
	  createStoryJS({
		  type:		'timeline',
		  width:		'100%',
      lang:     I18n.locale,
		  height:		String($(window).height()-$('.navbar').height()-$('footer').height()),
		  source:		gon.json_data,
		  embed_id:	'timeline-embed',
      hash_bookmark: true,
      start_zoom_adjust: -1,
		  debug:		true
	  });
  }
});
