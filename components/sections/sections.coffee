
@Sections = new Meteor.Collection 'sections'
@Choices = new Meteor.Collection 'choices'

Sections.before.insert (userId, doc)->
    doc.teacher_id = Meteor.userId()
    return


FlowRouter.route '/sections', action: ->
    BlazeLayout.render 'layout', 
        main: 'sections'

FlowRouter.route '/section/edit/:section_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_section'

FlowRouter.route '/section/view/:section_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'section_page'




if Meteor.isClient
    
    Template.edit_section.onCreated ->
        @autorun -> Meteor.subscribe 'section', FlowRouter.getParam('section_id')
        @autorun -> Meteor.subscribe 'section_choices', FlowRouter.getParam('section_id')
    
    Template.edit_section.events
        'click #save_section': ->
            title = $('#title').val()
            info = $('#info').val()
            question = $('#question').val()
            number = parseInt $('#number').val()
            section_id = FlowRouter.getParam('section_id')

            Sections.update section_id,
                $set: 
                    title: title
                    number: number
                    info: info
                    question: question
                , ->
                    FlowRouter.go "/section/view/#{section_id}"

        'click #delete_section': ->
            if confirm 'delete section?'
                Sections.remove FlowRouter.getParam('section_id')
                FlowRouter.go '/sections'
    
        'click #add_choice': ->
            Choices.insert
                section_id: @_id
    
    Template.question_choice.events
        'keyup .answer': (e,t)->
            e.preventDefault()
            answer = t.$('.answer').val().toLowerCase().trim()
            if e.which is 13 #enter
                Choices.update @_id,
                    $set: answer: answer
    
    Template.edit_section.helpers
        section: -> Sections.findOne FlowRouter.getParam('section_id')
        
        choices: ->
            Choices.find()
        
        
    Template.sections.onCreated ->
        @autorun -> Meteor.subscribe('sections')
    
    
    Template.section_page.onCreated ->
        @autorun -> Meteor.subscribe 'section', FlowRouter.getParam('section_id')
    
    
    
    Template.section_page.helpers
        section: -> Sections.findOne FlowRouter.getParam('section_id')
    
    
    
    Template.sections.helpers
        sections: ->  Sections.find {}
            
            
    Template.quiz.onCreated ->
        @autorun -> Meteor.subscribe('section_choices', FlowRouter.getParam('section_id'))
            
    Template.quiz.helpers
        choices: ->
            Choices.find()

    Template.sections.events
        'click #add_section': ->
            id = Sections.insert {}
            FlowRouter.go "/section/edit/#{id}"



if Meteor.isServer
    Sections.allow
        insert: (userId, doc) -> userId
        update: (userId, doc) -> userId or Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> userId or Roles.userIsInRole(userId, 'admin')
    
    Choices.allow
        insert: (userId, doc) -> userId
        update: (userId, doc) -> userId or Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> userId or Roles.userIsInRole(userId, 'admin')

    Meteor.publish 'section', (id)->
        Sections.find id

    Meteor.publish 'section_choices', (section_id)->
        Choices.find
            section_id: section_id
