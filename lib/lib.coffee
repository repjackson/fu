@Tags = new Meteor.Collection 'tags'


FlowRouter.notFound =
    action: ->
        BlazeLayout.render 'layout', 
            main: 'not_found'
        
        
