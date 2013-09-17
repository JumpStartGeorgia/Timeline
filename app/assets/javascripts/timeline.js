var timeline_data;
var search_index;
var geo_chars =
		['ა','ბ','გ','დ','ე','ვ','ზ','თ','ი','კ','ლ','მ','ნ','ო','პ','ჟ',
		'რ','ს','ტ','უ','ფ','ქ','ღ','ყ','შ','ჩ','ც','ძ','წ','ჭ','ხ','ჯ','ჰ'];
var eng_geo_chars =
		['a','b','g','d','e','v','z','t','i','k','l','m','n','o','p','zh',
		  'r','s','t','u','p','q','gh','qkh','sh','ch','ts','dz','ts','tch','kh','j','h'];
var was_search_box_length = 0;
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
	  createStoryJS({
		  type:		'timeline',
		  width:		'100%',
      lang:     I18n.locale,
		  height:		String($(window).height()-$('.navbar').height()-$('footer').height()),
		  source:		timeline_data,
		  embed_id:	'timeline-embed',
      hash_unique_bookmark: true,
      start_zoom_adjust: -1,
		  debug:		false,
		  start_at_end: true
	  });
  }

  // search for the provided text and then reload the timeline
  function search_timeline(query){
    var new_dates = search_index.search(change_geo_to_en(query)).map(function (result) {
      return gon.json_data.timeline.date[parseInt(result.ref, 10)] }
    );
    if (new_dates.length == 0){
      if (I18n.locale == 'ka'){
        alert('თქვენი საძიებო ფრაზის "' + query + '"  შედეგი არ მოიძებნა');
      }else {
        alert('Your search for "' + query + '" returned 0 results.');    
      }
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

  if (gon.show_timeline){
    // clone the json data so searching can search through the original
    timeline_data = JSON.parse(JSON.stringify(gon.json_data));

    generate_timeline();
    
	  // resize the timeline when the screen changes
    window.onresize = function()
    {
      $('#timeline-embed').css('height', String($(window).height()-$('.navbar').height()-$('footer').height()) + "px");
    }
    
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
    
    function load_social_buttons (id)
    {
      var item = $('#hidden_input_' + id).closest('.slider-item');

      var socials = item.find('.event_social_links');
      socials.children().each(function (){ $(this).empty(); });

      var url = location.href;

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
      var title = item.find(':input.title_here').parent().text() + ' - ' + $('meta[property="og:title"]').attr('content'); // if you don't specify the title, it will automatically get og:title

      //var spans = new Array(5).join('<span></span>');
      //$('#photo_title_social .likes').html(spans).children().attr('id', function (i){ return 'st_button_' + i; });

      stWidget.addEntry({
          "service": "facebook",
          "element": socials.children('.st_facebook_hcount')[0],
          "url": url,
          "title": title,
          "type": "hcount"
      });

      stWidget.addEntry({
          "service": "googleplus",
          "element": socials.children('.st_googleplus_hcount')[0],
          "url": url,
          "title": title,
          "type": "hcount"
      });

      stWidget.addEntry({
          "service": "twitter",
          "element": socials.children('.st_twitter_hcount')[0],
          "url": url,
          "title": title,
          "type": "hcount"
      });

      stWidget.addEntry({
          "service": "sharethis",
          "element": socials.children('.st_sharethis_hcount')[0],
          "url": url,
          "title": title,
          "type": "hcount"
      });
      
      $('#og_title').attr('content', title);
      $('#og_url').attr('content', url);


      item.find('.fb-like').attr('data-href', url);
      
    }
    
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
        url_ary = $(this).attr('href').split('#');
        $(this).attr('href', url_ary[0] + new_hash);
      });
      load_social_buttons(new_hash.split('#')[1]);
    })
    .load(function ()
    {
      var id = location.hash.length > 1 ? location.hash.split('#')[1] : $('.slider-item:last :input.hidden_input_id').val();
      load_social_buttons(id);
    });


    // if url has hash and language link does not when page loads, add it
    if (window.location.hash.length > 0){
      $('.lang_switcher a').each(function(){
        url_ary = $(this).attr('href').split('#');
        $(this).attr('href', url_ary[0] + window.location.hash);
      });
    }

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
    $('input#search_box').bind('keyup', debounce(function () {
      // if text length is 1 or the length has not changed (e.g., press arrow keys), do nothing
      if ($(this).val().length == 1 || $(this).val().length == was_search_box_length) {
        return;
      } else if ($(this).val().length == 0 && was_search_box_length > 0) {
        reload_timeline();      
      } else {
        search_timeline($(this).val());
      }
      was_search_box_length = $(this).val().length;
    }));
    // prevent the search box from submitting
    $('input#search_box').submit(function () {
      return false;
    });

  }
});
