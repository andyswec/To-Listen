/* universal */

$(function () {
    $('[data-toggle="popover"]').popover()
});

$(function () {
    var deleteErrors = function () {
        $(this).parent().removeClass('has-error has-feedback');
        $(this).parent().children('span').remove();
    };
    $('ul.users li.new-user input#last_fm_username[type=text]').on('input', deleteErrors);
});