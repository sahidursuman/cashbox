$(function () {

  'use strict';

  var organization = $('#current_organization').text().trim();

  if (location.pathname === "/" && location.search === '') {
    var current_user_id = $('.current_user_id').data('id');
    App.cable.subscriptions.create({
      channel: "MainPageChannel",
      organization: organization
    }, {
      received: function(data) {
        if (!(data['user_id'] === current_user_id)) {
          AddTransactionToList (
            data['id'],
            data['view'],
            data['sidebar'],
            data['total_balance']
          );
        }
      }
    });
  }

  function AddTransactionToList (element_id, element, sidebar, total_balance) {
    $(element).prependTo('.transactions').hide().fadeIn(1000);
    var bgc = $(element_id).css('backgroundColor');
    $(element_id).addClass('new-transaction');
    $(element_id).animate({
      backgroundColor: bgc,
    }, 1000 );
    $("#sidebar").replaceWith(sidebar);
    $("#total_balance").replaceWith(total_balance);
  }
});
