FlowRouter.route '/notecards', action: ->
    BlazeLayout.render 'layout', 
        main: 'notecards'

FlowRouter.route '/notecard/edit/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_notecard'

FlowRouter.route '/notecard/view/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'notecard_page'





if Meteor.isClient
    Template.notecards.onCreated ->
        @autorun -> Meteor.subscribe('selected_notecards', selected_tags.array())
    
    Template.notecards.onRendered ->
        $('#blog_slider').layerSlider
            autoStart: true
    
    
    Template.notecards.helpers
        notecards: -> 
            Docs.find {
                type: 'notecard'
                }
                
    Template.notecards.events
        'click #add_notecard': ->
            id = Docs.insert
                type: 'notecard'
            FlowRouter.go "/notecard/edit/#{id}"
    
    
    
    Template.edit_notecard.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.edit_notecard.helpers
        notecard: ->
            Docs.findOne FlowRouter.getParam('doc_id')
            
    Template.notecard_page.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    
    
    Template.notecard_page.helpers
        notecard: ->
            Docs.findOne FlowRouter.getParam('doc_id')
    
    
    Template.notecard_page.events
        'click .edit_notecard': ->
            FlowRouter.go "/notecard/edit/#{@_id}"
    
        
    Template.notecard_item.helpers
        tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'
    
        can_edit: -> @author_id is Meteor.userId()
    
        


    Template.notecard_item.events
        'click .notecard_tag': ->
            if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()
    
        'click .edit_notecard': ->
            FlowRouter.go "/notecard/edit/#{@_id}"


if Meteor.isServer
    Meteor.publish 'selected_notecards', (selected_notecard_tags)->
        
        self = @
        match = {}
        if selected_notecard_tags.length > 0 then match.tags = $all: selected_notecard_tags
        match.type = 'notecard'
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        
    
        Docs.find match
    
    Meteor.publish 'notecard', (doc_id)->
        Docs.find doc_id
    
        
