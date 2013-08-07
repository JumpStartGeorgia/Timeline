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
		  debug:		false,
		  start_at_end: true
	  });

    // when the hash changes, update the language switcher to also have this hash
    $(window).on('hashchange', function() {
      var old_hash;
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
