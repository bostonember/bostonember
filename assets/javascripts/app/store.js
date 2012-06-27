App.Store = DS.Store.extend({
  revision: 4,
  adapter: DS.RESTAdapter.create({ namespace: 'api' })
});

App.store = App.Store.create();
