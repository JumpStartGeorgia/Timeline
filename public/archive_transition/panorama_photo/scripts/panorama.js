$(document).ready(function() {

  // if screen is small, switch out the background image
  if ($(window).width() < 427){
    $('#panorama').prop('src', 'panorama_photo/images/bg_mobile_small.jpg');
  }else if ($(window).width() < 623){
    $('#panorama').prop('src', 'panorama_photo/images/bg_mobile_big.jpg');
  }else{
    $('#panorama').prop('src', 'panorama_photo/images/bg_static.jpg');
  }

  // adjust image to start with statue in middle of circle
  // formula: (frames to middle) - ( (1/2 width of screen) / (frame width) )
  var img_ratio = $(window).height() / $('#panorama').data('orig-height');
  var new_width = $('#panorama').data('orig-width') * img_ratio;
  var frames_middle = 1086;
  var frame_width = new_width / $('#panorama').data('frames');
  var new_f = frames_middle - ($(window).width()/2/frame_width);

  // make image fit height of screen
  var panoramaResize = function()
  {
    var ratio = $(window).height() / $('#panorama').data('orig-height');
    var new_height = $('#panorama').data('orig-height') * ratio;
    var new_width = $('#panorama').data('orig-width') * ratio;
    $('#panorama').css('height', new_height).css('background-size',  new_width + 'px ' + new_height + 'px');
//      $('#panorama').css('height', new_height).css('background-size',  '4344px ' + new_height + 'px');
//      $('#panorama').css('width', new_width);
    $('#panorama').data('stitched', new_width);
    $('#panorama-reel').css('height', $(window).height());
  }
  panoramaResize();

  // resize the panorama timeline when the screen changes
  window.onresize = function()
  {
    panoramaResize();
  }

  // if this is not a small screen, turn on the scrolling panaorama
  if ($(window).width() > 978){
    $('#panorama').data('frame', new_f);
    $('#panorama').reel($('#panorama').data());
  }
});
