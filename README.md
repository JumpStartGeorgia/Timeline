#Gudiashvili Timeline

This is a rails app that uses timeline.js to render events in a nice timeline format.  Features of the site include:
* TimelineJS - https://github.com/VeriteCo/TimelineJS/
* lunrjs (for searching through timeline text) - http://lunrjs.com/
* generating and caching json files of timeline data from database so pages load quicker
* automatically saving images locally to avoid issues of images disappearing on the web

## Archive Transition Article

This branch contains separate static files (html, css and JS) for the Timeline and Panorama Photo in Archive Transition's article about the history of Gudiashvili Square.

- The files are located in the directory `public/archive_transition`
- The data for the timeline is located at:
  - `http://gudiashvili.jumpstart.ge/en/timeline_events.json` (English)
  - `http://gudiashvili.jumpstart.ge/ka/timeline_events.json` (Georgian)
