/* universal */

$(function () {
    $('[data-toggle="popover"]').popover()
})

//$(document).ready(function() {
//    $('#new-user-form').bind("ajax:success", function(evt, data, status, xhr) {
//        var $form = $(this);
//        //TODO reset form
//
//        $('ul#users li:last').before(xhr.responseText)
//    })
//})