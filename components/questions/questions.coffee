
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
    answers: -> Answers.find question_id: @_id

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
        'blur .answer': (e,t)->
            answer = t.$('.answer').val().toLowerCase().trim()
            Answers.update @_id,
                $set: answer: answer
                    
        'blur .response': (e,t)->
            response = t.$('.response').val().toLowerCase().trim()
            Answers.update @_id,
                $set: response: response
                    
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
        @autorun -> Meteor.subscribe 'questions'
    
    
    
    
    
    Template.question_page.onCreated ->
        @autorun -> Meteor.subscribe 'question', FlowRouter.getParam('question_id')
        @answered = new ReactiveVar false 
        @answer_id = new ReactiveVar '' 

    Template.question_page.helpers
        question: -> Questions.findOne {}
        answers: -> Answers.find()
        is_answered: -> Template.instance().answered.get()
        answer_class: -> 
            button_class = ''
            if Template.instance().answer_id.get() is @_id
                button_class += 'green'
            if Template.instance().answered.get() is true
                button_class += ' disabled'
            # else button_class += 'basic'
            console.log button_class
            button_class
            
        selected_answer: ->
            Template.instance().answer_id.get() is @_id and Template.instance().answered.get() is true
    
    Template.question_page.events
        'click .pick_answer': (e,t)->
            if @right then Meteor.users.update Meteor.userId(), $addToSet: right_questions: @_id
            else Meteor.users.update Meteor.userId(), $addToSet: wrong_questions: @_id
            
            t.answered.set true
            t.answer_id.set @_id

    Template.questions.helpers
        questions: ->  Questions.find {}
            
            

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

    Meteor.publish 'answers', (question_id)->
        Answers.find
            question_id: question_id


    publishComposite 'module_questions', (module_id)->
        {
            find: ->
                Questions.find {},
                    sort: number: -1
                    # limit: 10
            children: [
                { find: (question) ->
                    Answers.find { question_id: question._id }
                }
                {
                    find: (question) ->
                        Modules.find { _id: question.module_id } 
                }
            ]
        }

    publishComposite 'question', (question_id)->
        {
            find: ->
                Questions.find _id:question_id
            children: [
                { find: (question) ->
                    Answers.find { question_id: question._id }
                }
                {
                    find: (question) ->
                        Modules.find { _id: question.module_id } 
                }
            ]
        }

