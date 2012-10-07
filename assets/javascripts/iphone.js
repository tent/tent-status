(function($){
  // currently running as iOS webclip?
  if(window.navigator.standalone){
    // attach event handler to every link
    $('html>body').on('click','a',function(event){
      var href = $(this).attr('href');
      // load links to tent.is inside of the webclip
      if(/^https?:\/\/([^.]+\.)?tent\.is\/|$/.test(href)){
        event.preventDefault();
        event.stopPropagation();
        window.location = href;
        return false;
      };
    });
  };
})(jQuery)