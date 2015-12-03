var timeline_data;
var search_index;
var geo_chars =
		['ა','ბ','გ','დ','ე','ვ','ზ','თ','ი','კ','ლ','მ','ნ','ო','პ','ჟ',
		'რ','ს','ტ','უ','ფ','ქ','ღ','ყ','შ','ჩ','ც','ძ','წ','ჭ','ხ','ჯ','ჰ'];
var eng_geo_chars =
		['a','b','g','d','e','v','z','t','i','k','l','m','n','o','p','zh',
		  'r','s','t','u','p','q','gh','qkh','sh','ch','ts','dz','ts','tch','kh','j','h'];
var was_search_box_length = 0;
var hash_marker = '#!';

// lunr.js does not work with geo chars so convert to eng chars
function change_geo_to_en(text){
  var new_text = new String(text);
  if (I18n.locale == 'ka'){
    for (var i=0;i<geo_chars.length;i++){
      new_text = new_text.replace(new RegExp(geo_chars[i], "g"), eng_geo_chars[i]);
    }
  }
  return new_text;
}

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


    // when the hash changes,
    // - change the hash to use the id from the table record
    // - update the language switcher to also have this hash
    $(window).on('hashchange', function() {
      var new_hash = "#_"
      if (window.location.hash.length >= 2 && window.location.hash != new_hash)
      {
//        new_hash = "#" + gon.json_data.timeline.date[window.location.hash.replace(/#/g, '')].id;
//        window.location.hash = new_hash;
        new_hash = window.location.hash;
      }
      $('.lang_switcher a').each(function(){
        url_ary = $(this).attr('href').split(hash_marker);
        $(this).attr('href', url_ary[0] + new_hash);
      });

    })

    check_items(50);
  }
}

var i = 0;

// search for the provided text and then reload the timeline
sabt = 0;
function search_timeline(query){
  var new_dates = search_index.search(change_geo_to_en(query)).map(function (result) {
    return gon.json_data.timeline.date[parseInt(result.ref, 10)] }
  );
  if (new_dates.length == 0){
    var alertbox = $('#search-alert'),
    searchbox = $('#search_box');
    alertbox.html(alertbox.html().replace(alertbox.data('query'), query)).data('query', query).stop(true, true).css({left: searchbox.offset().left, width: searchbox.outerWidth()}).fadeIn();
    clearTimeout(sabt);
    sabt = setTimeout(function (){ alertbox.fadeOut(); }, 4000);
  }else{
    timeline_data.timeline.date = new_dates;
    $(global).unbind();
    $('#timeline-embed').html('');
    generate_timeline();
    window.location.hash = "_";
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

  // if url has hash
  // - scroll down to timeline
  // - and language link does not when page loads, add it
  if (window.location.hash.length > 0){
    $('.lang_switcher a').each(function(){
      url_ary = $(this).attr('href').split('#');
      $(this).attr('href', url_ary[0] + window.location.hash);
    });

    $('html, body').animate({
      scrollTop: $("#timeline-embed").offset().top
    }, 2000);
  }

  // if url has tag or category params, scroll down to timeline
  (window.onpopstate = function () {
      var match,
          pl     = /\+/g,  // Regex for replacing addition symbol with a space
          search = /([^&=]+)=?([^&]*)/g,
          decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
          query  = window.location.search.substring(1);

      urlParams = {};
      while (match = search.exec(query))
         urlParams[decode(match[1])] = decode(match[2]);

      if ('category' in urlParams || 'tag' in urlParams){
        $('html, body').animate({
          scrollTop: $("#timeline-embed").offset().top
        }, 2000);
      }
  })();

});
