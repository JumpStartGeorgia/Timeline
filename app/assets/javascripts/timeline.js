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

function calculate_timeline_height() {
	return String($(window).height()-$('.navbar').outerHeight()-$('footer').outerHeight());
}

  function generate_timeline(){

    if (!$.isEmptyObject(gon.json_data)){
	    createStoryJS({
		    type:		'timeline',
		    width:		'100%',
        lang:     I18n.locale,
		    height:		calculate_timeline_height(),
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
        load_social_buttons(new_hash.split(hash_marker)[1]);

      })

      check_items(50);
    }
  }

  var i = 0;
  // load the social buttons for the items in the timeline
  function check_items (maxi)
  {
    if (i < maxi)
    {
      var id = location.hash.match(/[0-9]+$/);
      if (id && $('#hidden_input_' + id[0]).length || $('.slider-item:last :input.hidden_input_id').length)
      {
        var id = id ? id[0] : $('.slider-item:last :input.hidden_input_id').val();
        load_social_buttons(id);
        $('.content .credit a').attr('target', '_blank');
        i = 0;
        return;
      }
      i ++;
      setTimeout(check_items, 150, maxi);
    }
  }

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


  function load_social_buttons(id)
  {
    var item = $('#hidden_input_' + id).closest('.slider-item');
    if (item.length == 0)
    {
      return;
    }

    var socials = item.find('.event_social_links');
    socials.children().not('.fbshare').each(function (){ this.innerHTML = ''; });

    var url = location.href;
    if (window.location.hash.length == 0){
      // id is not in url yet, so add it for sharing
      url += hash_marker + id;
    }

  /*
    var sep = '><|-'.split(''),
    sep_reg = [];
    for (var i = 0; i < sep.length; i ++)
    {
      sep_reg.push('\\' + sep[i]);
    }
    sep_reg = new RegExp('(.|\\s)*\\s+(' + sep_reg.join('|') + ')+\\s+(.|\\s)+');
    console.log(sep_reg, 'soldier > timeline'.match(sep_reg));
  */
    var twitter_title = item.find(':input.title_here').parent().text();
    var title = twitter_title + ' - ' + $('meta[property="og:title"]').data('original-content');//if you don't specify the title, it'll automatically get og:title

    //var spans = new Array(5).join('<span></span>');
    //$('#photo_title_social .likes').html(spans).children().attr('id', function (i){ return 'st_button_' + i; });

  /*
    stWidget.addEntry({
        "service": "facebook",
        "element": socials.children('.st_facebook_hcount')[0],
        "url": url,
        "title": title,
        "type": "hcount"
    });
  */

//    var summary = item.find('.content .content-container .text .container p').text();
//    var img = item.find('img.media-image').length ? item.find('img.media-image')[0].src : $('meta[property="og:image"]').attr('content');

//    item.find('.fbshare').attr('href', 'http://www.facebook.com/sharer.php?s=100&p[url]=' + encodeURIComponent(url) + '&p[images][0]=' + encodeURIComponent(img) + '&p[title]=' + title + '&p[summary]=' + summary);

      item.find('.fbshare').attr('href', 'https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(url));
      item.find('.twitter-share-button').attr('href', 'https://twitter.com/share?url=' + encodeURIComponent(url) + '&text=' + encodeURIComponent(twitter_title) + '&via=jsgeorgia&hashtags=' + gon.hash_tag)

/*
    stWidget.addEntry({
        "service": "facebook",
        "element": socials.children('.st_facebook_custom')[0],
        "url": url,
        "title": title,
        "image": img,
        "type": "custom"
    });
*/

// $(socials.children('.st_twitter_custom')[0]).attr('st_url', url).attr('st_title', title);
// $(socials.children('.st_sharethis_custom')[0]).attr('st_url', url).attr('st_title', title);

/*
    stWidget.addEntry({
        "service": "twitter",
        "element": socials.children('.st_twitter_custom')[0],
        "url": url,
        "title": title,
        "type": "custom"
    });

    stWidget.addEntry({
        "service": "sharethis",
        "element": socials.children('.st_sharethis_custom')[0],
        "url": url,
        "title": title,
        "type": "custom"
    });
*/
  }

$(document).ready(function() {


  if (gon.show_timeline){
    // clone the json data so searching can search through the original
    timeline_data = JSON.parse(JSON.stringify(gon.json_data));

    generate_timeline();

    // create index of all items in timeline for searching
    search_index = lunr(function () {
      this.field('title'),
      this.field('body'),
      this.ref('id')
    });

    var s_title, s_body;
    for (var i=0; i<gon.json_data.timeline.date.length; i++){
      // remove any html and just keep plain text
      search_index.add({
        id: i,
        title: change_geo_to_en(gon.json_data.timeline.date[i].headline),
        body: change_geo_to_en($(gon.json_data.timeline.date[i].text).text())
      })
    };





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

    // search box
    var debounce = function (fn) {
      var timeout
      return function () {
        var args = Array.prototype.slice.call(arguments),
            ctx = this

        clearTimeout(timeout)
        timeout = setTimeout(function () {
          fn.apply(ctx, args)
        }, 500)
      }
    }

    // perform search
    $('input#search_box')
    .bind('keyup', debounce(function () {
      // if text length is 1 or the length has not changed (e.g., press arrow keys), do nothing
      if ($(this).val().length == 1 || $(this).val().length == was_search_box_length) {
        return;
      } else if ($(this).val().length == 0 && was_search_box_length > 0) {
        reload_timeline();
      } else {
        search_timeline($(this).val());
      }
      was_search_box_length = $(this).val().length;
    }))
    .keyup(function () {
      if ($(this).val().length == 0)
      {
        $(this).parent().removeClass('focused');
      }
      else
      {
        $(this).parent().addClass('focused');
      }
    })
    .siblings('.imgs').children('img:last').click(function (){ $(this).parent().siblings('input').val('').keyup().focus(); });
    // prevent the search box from submitting
    $('input#search_box').submit(function () {
      return false;
    });

  }

});
