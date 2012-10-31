$('.typeahead-box').typeahead({
  source: function (query, process) {
    $.getJSON("/api/get_all_titles", function (data) {
      process(data);
    }, "json");
  }
});

if (!sessionStorage.getItem("was_introduced")) {
  $('.typeahead-box').popover({
      placement: "bottom"
    , trigger: "manual"
    , content: "Search for pages or create new ones straight from the search box!"
  }).popover('show');

  $('.typeahead-box').click( function () {
    $('.typeahead-box').popover('destroy');
  });

  sessionStorage.setItem("was_introduced", true);
};

