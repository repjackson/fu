
FlowRouter.route '/notecards', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'notecards'

FlowRouter.route '/notecard/edit/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_notecard'


if Meteor.isClient
    Template.edit_notecard.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.edit_notecard.helpers
        notecard: -> Docs.findOne FlowRouter.getParam('doc_id')

    Template.edit_notecard.events
        'blur #front': ->
            front = $('#front').val()
            Docs.update FlowRouter.getParam('doc_id'),
                $set: front: front
                
        'blur #back': ->
            back = $('#back').val()
            Docs.update FlowRouter.getParam('doc_id'),
                $set: back: back
                

    Template.notecard_card.onRendered ->
        $('.shape').shape()

    Template.notecard_card.events
        'click .side': (e,t)->
            t.$('.shape').shape('flip over')
