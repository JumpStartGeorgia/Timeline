function show_about() {
  $('.js-make-about-showable-hideable').removeClass('is-hidden');
}

function hide_about() {
  $('.js-make-about-showable-hideable').addClass('is-hidden');
}

function setup_about() {
  $('.js-show-about-box').click(show_about);

  $('.js-hide-about-box').click(hide_about);
}
