$(document).ready(function() {
  $('#dealer_hits').click(function(){
    $.ajax({
      type: 'GET',
      url: '/dealer_hit'
    }).done(function(msg) { 
      $('#dealers_turn').replaceWith(msg);
    });
  });
});