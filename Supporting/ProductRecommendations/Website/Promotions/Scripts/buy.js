$(document).ready(function ($) { 
    'use strict';
    $('.buy-button').click(function(e){
        e.preventDefault();
        
        var id = $(e.target).data('id');
        
        $(e.target).replaceWith('<p id="purchasing"><img src="/Content/spinner.gif" />Purchasing...</p>');
        
        $.post('/Home/Buy', {Id: id})
        .done(function(){
            $('#purchasing').replaceWith('Purchase complete');
        })
        .fail(function(){
            $('#purchasing').replaceWith('Purchase failed');
        });
    });
}(window.jQuery));
