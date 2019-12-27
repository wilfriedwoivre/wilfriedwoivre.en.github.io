function search() {
    input = $("#search-input").val().toLowerCase();

    var results = searchData.reduce(function (a, e, i) 
    { 
        if (e.title.includes(input) || e.categories.includes(input)) 
            a.push(e.url); 
        return a;
    }, []);

    $(".blog-post").each(function (i, e){
        if (results.includes(e.attributes['data-url'].value)) {
            $(this).show();
        } else {
            $(this).hide();
        }
    });

}

$("#search-input").keyup(search);