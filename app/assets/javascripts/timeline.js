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
		  debug:		false
	  });

	  // resize the timeline when the screen changes
    window.onresize = function()
    {
      $('#timeline-embed').css('height', String($(window).height()-$('.navbar').height()-$('footer').height()) + "px");
    }

    // when the hash changes, 
    // - change the hash to use the id from the table record
    // - update the language switcher to also have this hash
    $(window).on('hashchange', function() {
      $('.lang_switcher a').each(function(){
        url_ary = $(this).attr('href').split('#');
        $(this).attr('href', url_ary[0] + window.location.hash);
      });
    });

    // if url has hash and language link does not when page loads, add it
    if (window.location.hash.length > 0){
      $('.lang_switcher a').each(function(){
        url_ary = $(this).attr('href').split('#');
        $(this).attr('href', url_ary[0] + window.location.hash);
      });
    }
  }
});
