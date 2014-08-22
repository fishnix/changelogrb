
// instantiate the bloodhound suggestion engine
// prefetch tags from api (only cache for 10s, so new tags will show up)
var tags = new Bloodhound({  
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: {
    url: "/api/tags",
    ttl: 10000,
    filter: function(list) {
      return $.map(list, function(tag) {
        return { value: tag }; });
    }
  }
});

// initialize the bloodhound suggestion engine
tags.initialize();

// do the typeahead magic
$('#cl_tag').tagsinput({
  typeaheadjs: {
    name: 'tags',
    displayKey: 'value',
    valueKey: 'value',
    source: tags.ttAdapter()
  }
});

