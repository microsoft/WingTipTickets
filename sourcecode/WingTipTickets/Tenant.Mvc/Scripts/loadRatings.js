function loadRatings() {
    var price = $("#slctPriceSection").val().split("|")[0];

    $.ajax({
        url: "/home/GetRatings?concertId=" + getParameterByName('concertId') + "&priceId=" + price.substring(0, price.length - 3),
        success: function (rating) {
            drawRatings(rating);
        },
        error: function () {
            $("#ratings").hide();
        }
    })
}