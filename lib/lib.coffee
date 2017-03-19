@Tags = new Meteor.Collection 'tags'


FlowRouter.notFound =
    action: ->
        FlowRouter.go '/'