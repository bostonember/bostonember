App.Meeting = DS.Model.extend({
  name: DS.attr("string"),
  event_url: DS.attr("string")
});

App.Member = DS.Model.extend({
  name: DS.attr("string"),
  link: DS.attr("string"),
  photo_link: DS.attr("string"),
  thumb_link: DS.attr("string")
});
