FlowRouter.route '/edit/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit'



if Meteor.isClient
    Template.edit.onCreated ->
        self = @
        self.autorun ->
            self.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    
    Template.edit.helpers
        doc: ->
            Docs.findOne FlowRouter.getParam('doc_id')
        
    
            
            
    Template.edit.events
        'click #save': ->
            FlowRouter.go "/view/#{FlowRouter.getParam('doc_id')}"
