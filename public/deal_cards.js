$(document).ready(function() {
  $('#hit_button').click(function(){
    $.ajax({
      type: 'GET',
      url: '/player_hit'
    }).done(function(msg) { 
      $('#deal_cards').replaceWith(msg);
    });
  });
  $('#stay_button').click(function(){
    $.ajax({
      type: 'GET',
      url: '/dealer_hit'
    }).done(function(msg) {
      $('#deal_cards').replaceWith(msg);
    });
  });
});