if Meteor.isClient
    Template.nav.events
        'click #logout': -> AccountsTemplates.logout()

    Template.nav.onCreated ->
        @autorun -> Meteor.subscribe 'user'



if Meteor.isServer
    Meteor.publish 'user', ->
        Meteor.users.find @userId,
            fields:
                profile: 1
                right_questions: 1
                wrong_questions: 1
                completed_modules: 1
                completed_courses: 1