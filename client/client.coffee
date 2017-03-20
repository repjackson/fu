
Template.registerHelper 'is_teacher', () ->  Meteor.userId() is @teacher_id

Template.registerHelper 'can_edit', () ->  Meteor.userId() is @teacher_id or Roles.userIsInRole(Meteor.userId(), 'admin')

Template.registerHelper 'is_dev', () -> Meteor.isDevelopment
