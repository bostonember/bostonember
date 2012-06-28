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

      showMember: Ember.Route.transitionTo('members.show'),

      connectOutlets: function(router) {
        router.get('applicationController').connectOutlet('members', App.Member.find());
      },

      index: Ember.Route.extend({
        route: '/'
      }),

      show: Ember.Route.extend({
        route: '/:member_id',

        connectOutlets: function(router, member) {
          router.get('membersController').connectOutlet('member', member);
        }
      })
    })
  })
});
