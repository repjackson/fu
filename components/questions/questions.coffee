
@Questions = new Meteor.Collection 'questions'
@Answers = new Meteor.Collection 'answers'

Questions.before.insert (userId, doc)->
    doc.teacher_id = Meteor.userId()
    return


FlowRouter.route '/questions', action: ->
    BlazeLayout.render 'layout', 
        main: 'questions'

FlowRouter.route '/question/edit/:question_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_question'

FlowRouter.route '/question/view/:question_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'question_page'

Questions.helpers
    module: -> Modules.findOne @module_id

Answers.helpers
    question: -> Questions.findOne @question_id



if Meteor.isClient
    
    Template.edit_question.onCreated ->
        @autorun -> Meteor.subscribe 'question', FlowRouter.getParam('question_id')
        @autorun -> Meteor.subscribe 'answers', FlowRouter.getParam('question_id')
    
    Template.edit_question.events
        'click #save_question': ->
            title = $('#title').val()
            info = $('#info').val()
            question = $('#question').val()
            number = parseInt $('#number').val()
            question_id = FlowRouter.getParam('question_id')

            Questions.update question_id,
                $set: 
                    title: title
                    number: number
                    info: info
                    question: question
                , ->
                    FlowRouter.go "/question/view/#{question_id}"

        'click #delete_question': ->
            if confirm 'delete question?'
                Questions.remove FlowRouter.getParam('question_id')
                FlowRouter.go '/questions'
    
        'click #add_answer': ->
            Answers.insert
                question_id: @_id
    
    Template.answer.events
        'keyup .answer': (e,t)->
            e.preventDefault()
            answer = t.$('.answer').val().toLowerCase().trim()
            if e.which is 13 #enter
                Answers.update @_id,
                    $set: answer: answer
                    
        'click .make_right': ->
            Answers.update @_id,
                $set: right: true

        'click .make_wrong': ->
            Answers.update @_id,
                $set: right: false
    
    Template.edit_question.helpers
        question: -> Questions.findOne FlowRouter.getParam('question_id')
        
        
        answers: ->
            Answers.find()
        
        getFEContext: ->
            @current_doc = Questions.findOne FlowRouter.getParam('question_id')
            self = @
            {
                _value: self.current_doc.text
                _keepMarkers: true
                _className: 'froala-reactive-meteorized-override'
                toolbarInline: false
                initOnClick: false
                imageInsertButtons: ['imageBack', '|', 'imageByURL']
                tabSpaces: false
                height: 300
                '_onsave.before': (e, editor) ->
                    # Get edited HTML from Froala-Editor
                    newHTML = editor.html.get(true)
                    # Do something to update the edited value provided by the Froala-Editor plugin, if it has changed:
                    if !_.isEqual(newHTML, self.current_doc.text)
                        # console.log 'onSave HTML is :' + newHTML
                        Questions.update { _id: self.current_doc._id }, $set: text: newHTML
                    false
                    # Stop Froala Editor from POSTing to the Save URL
            }

        
    Template.edit_question.helpers
        'blur .froala-container': (e,t)->
            html = t.$('div.froala-reactive-meteorized-override').froalaEditor('html.get', true)
            
            question_id = FlowRouter.getParam('question_id')
    
            Questions.update question_id,
                $set: 
                    text: html



        
    Template.questions.onCreated ->
        @autorun -> Meteor.subscribe('questions')
    
    
    Template.question_page.onCreated ->
        @autorun -> Meteor.subscribe 'question', FlowRouter.getParam('question_id')
    
    
    
    Template.question_page.helpers
        question: -> Questions.findOne FlowRouter.getParam('question_id')
    
    
    
    Template.questions.helpers
        questions: ->  Questions.find {}
            
            
    Template.quiz.onCreated ->
        @autorun -> Meteor.subscribe('answers', FlowRouter.getParam('question_id'))
            
    Template.quiz.helpers
        answers: ->
            Answers.find()

    Template.questions.events
        'click #add_question': ->
            id = Questions.insert {}
            FlowRouter.go "/question/edit/#{id}"




if Meteor.isServer
    Questions.allow
        insert: (userId, doc) -> userId
        update: (userId, doc) -> userId or Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> userId or Roles.userIsInRole(userId, 'admin')
    
    Answers.allow
        insert: (userId, doc) -> userId
        update: (userId, doc) -> userId or Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> userId or Roles.userIsInRole(userId, 'admin')

    Meteor.publish 'question', (id)->
        Questions.find id

    Meteor.publish 'answers', (question_id)->
        Answers.find
            question_id: question_id
