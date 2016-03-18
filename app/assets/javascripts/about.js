function setup_about() {
  $('.js-show-about-box').click(function() {
    $('.js-make-about-showable-hideable').removeClass('is-hidden');
  });

  $('.js-hide-about-box').click(function() {
    $('.js-make-about-showable-hideable').addClass('is-hidden');
  });
}
