$(document).ready(function(){
    $('.dropdown-language').click(function(){
        $('.dropdown-user-content').hide();
        $('.dropdown-language-content').toggle();
    });

    $('.dropdown-user').click(function(){
        $('.dropdown-language-content').hide();
        $('.dropdown-user-content').toggle();
    });

    $('.dropdown-user').keypress(function (e) {
        var key = e.which;
        if(key == 13)  // the enter key code
        {
            $('.dropdown-language-content').hide();
            $('.dropbtn_userinfo').next().toggle();
        }
    });

    $('.dropdown-language').keypress(function (e) {
        var key = e.which;
        if(key == 13)  // the enter key code
        {
            $('.dropdown-user-content').hide();
            $('.dropbtn_language').next().toggle();
        }
    });


    $('.dropdown button').on('keydown', function(e){
        var charCode = (e.which) ? e.which : e.keyCode;
        if(charCode === 13 || charCode === 32 || charCode === 40){
            // 13 - enter, 32 - spacebar, 40 - down arrow
            e.preventDefault();
            $(this).siblings('.dropdown-content').show().find('a:first').focus();
        } else if(charCode === 37){
            // 37 - left arrow
            e.preventDefault();
            $(this).closest('.dropdown').next('.dropdown').find('button').focus();
        }else if(charCode === 39){
            // 39 - right arrow
            e.preventDefault();
            $(this).closest('.dropdown').prev('.dropdown').find('button').focus();
        }
    });

    $('.dropdown a').on('keydown', function(e){
        var charCode = (e.which) ? e.which : e.keyCode;
        if(charCode === 38 || (e.shiftKey && charCode === 9)){
            // 38 - up arrow, 9 - tab
            e.preventDefault();
            if($(this).prev('a').length === 0){
                $(this).closest('.dropdown-content').removeAttr('style').prev('button').focus()
            }else {
                $(this).prev('a').focus();
            }
        }else if(charCode === 40 || charCode === 9){
            // 40 - down arrow, 9 - tab
            e.preventDefault();
            if($(this).next('a').length === 0){
                $(this).closest('.dropdown-content').removeAttr('style').prev('button').focus()
            }else {
                $(this).next('a').focus();
            }
        }
    });

    $('.wasteEditor-wasteType').on('keydown',function(e){
        var charCode = (e.which) ? e.which : e.keyCode;
        if(charCode === 37){
            // 37 - left arrow
            $(this).prev('.wasteEditor-wasteType').focus();
        }else if(charCode === 39){
            // 39 - right arrow
            $(this).next('.wasteEditor-wasteType').focus();
        }
    });

    $('.measurement_type a, .filter_type a').on('keydown',function(e){
        var charCode = (e.which) ? e.which : e.keyCode;
        if(charCode === 37){
            // 37 - left arrow
            $(this).prev('a').focus();
        }else if(charCode === 39){
            // 39 - right arrow
            $(this).next('a').focus();
        }
    });

    $('.row').on('click',function(){
        $('.dropdown-content').removeAttr('style')
    });

    $('.modal').on('shown.bs.modal', function (e) {
        var $modal = $(this);
        $modal.find('.close').focus();
        $('.dropdown-content').removeAttr('style')
    });

    $('.modal .last-link').on('focus',function(){
        $(this).closest('.modal').find('.close').focus();
    });

    $('#store_id').on("focus", function(e) {
        $('#store_id').select2('open');
    });


});

$(document).keyup(function(e) {
    if (e.keyCode == 27) {
        $('.dropdown-user-content').hide();
        $('.dropdown-language-content').hide();
        $('.close').click();
        $('.modal-backdrop').remove();
    }
});

