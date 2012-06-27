App.Router = Ember.Router.extend({
  root: Ember.Route.extend({
    index: Ember.Route.extend({
      route: '/',
      redirectsTo: 'meetings'
    }),

    showMeetings: Ember.Route.transitionTo('meetings'),

    showMembers: Ember.Route.transitionTo('members'),

    meetings: Ember.Route.extend({
      route: '/meetings',
      connectOutlets: function(router) {
        var applicationController = router.get('applicationController');
        applicationController.connectOutlet('meetings', App.Meeting.find());
      }
    }),

    members: Ember.Route.extend({
      route: '/members',
      connectOutlets: function(router) {
        var applicationController = router.get('applicationController');
        applicationController.connectOutlet('members', App.Member.find());
      }
    })
  })
});
