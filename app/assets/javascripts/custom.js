/* universal */

$(function () {
    $('[data-toggle="popover"]').popover()
});

$(function () {
    deleteIcons = function () {
        $(this).removeClass('has-error has-feedback');
        $(this).children('span').remove();
    };

    displayLoading = function () {
        $(this).addClass('has-feedback')
            .append('<span class="glyphicon glyphicon-refresh glyphicon-spin form-control-feedback" aria-hidden="true"></span>')
            .append('<span id="inputLoadingStatus" class="sr-only">(error)</span>');
    };

    enableInput = function() {
        $(this).attr('disabled', false);
    };

    disableInput = function() {
        $(this).attr('disabled', true);
    };

    $('ul.users li input#last_fm_username[type=text]').on('input', function () {
        deleteIcons.call($(this).parent());
    });

    $('ul.users li form#last-fm-form').bind('ajax:beforeSend', function () {
        disableInput.call($(this).find('input#last_fm_username[type=text]'));
        deleteIcons.call($(this).find('div.form-group'));
        displayLoading.call($(this).find('div.form-group'));
    });
});