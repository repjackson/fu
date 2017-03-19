FlowRouter.route '/decks', action: ->
    BlazeLayout.render 'layout', 
        main: 'decks'

FlowRouter.route '/deck/edit/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_deck'

FlowRouter.route '/deck/view/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'deck_page'





if Meteor.isClient
    Template.decks.onCreated ->
        @autorun -> Meteor.subscribe('selected_decks', selected_tags.array())
    
    
    Template.decks.helpers
        decks: -> 
            Docs.find {
                type: 'deck'
                }
                
    Template.decks.events
        'click #add_deck': ->
            id = Docs.insert
                type: 'deck'
            FlowRouter.go "/deck/edit/#{id}"
    
    
    
    Template.edit_deck.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.edit_deck.helpers
        deck: -> Docs.findOne FlowRouter.getParam('doc_id')
            
    Template.deck_page.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
        @autorun -> Meteor.subscribe 'deck_notecards', FlowRouter.getParam('doc_id')
    
    
    
    Template.deck_page.helpers
        deck: -> Docs.findOne FlowRouter.getParam('doc_id')
    
        notecards: ->
            Docs.find
                type: 'notecard'
                deck_id: FlowRouter.getParam('doc_id')
        
    Template.deck_page.events
        'click .edit_deck': ->
            FlowRouter.go "/deck/edit/#{@_id}"
    
        'click #add_card': ->
            new_id = Docs.insert
                type: 'notecard'
                deck_id: @_id
            FlowRouter.go "/notecard/edit/#{new_id}"
    
        
    
        
    Template.deck_card_view.helpers
        tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'
    
        can_edit: -> @author_id is Meteor.userId()
    
        


    Template.deck_card_view.events
        'click .deck_tag': ->
            if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()
    
        'click .edit_deck': ->
            FlowRouter.go "/deck/edit/#{@_id}"


if Meteor.isServer
    Meteor.publish 'selected_decks', (selected_deck_tags)->
        
        self = @
        match = {}
        if selected_deck_tags.length > 0 then match.tags = $all: selected_deck_tags
        match.type = 'deck'
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        
    
        Docs.find match
    
    Meteor.publish 'deck', (doc_id)->
        Docs.find doc_id
    
    Meteor.publish 'deck_notecards', (deck_id)->
        Docs.find
            type: 'notecard'
            deck_id: deck_id