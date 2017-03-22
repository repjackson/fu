
@Modules = new Meteor.Collection 'modules'

Modules.before.insert (userId, doc)->
    doc.teacher_id = Meteor.userId()
    return


FlowRouter.route '/modules', action: ->
    BlazeLayout.render 'layout', 
        main: 'modules'

FlowRouter.route '/module/edit/:module_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_module'

FlowRouter.route '/module/admin_view/:module_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'module_admin_page'

FlowRouter.route '/module/study/:module_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'study_module'

Modules.helpers
    course: -> Courses.findOne _id: @course_id

if Meteor.isClient
    Template.edit_module.onCreated ->
        @autorun -> Meteor.subscribe 'module', FlowRouter.getParam('module_id')
        @autorun -> Meteor.subscribe 'module_course', FlowRouter.getParam('module_id')
    
    Template.edit_module.events
        'click #save_module': ->
            title = $('#title').val()
            number = parseInt $('#number').val()
            module_id = FlowRouter.getParam('module_id')

            Modules.update module_id,
                $set: 
                    title: title
                    number: number
                , ->
                    FlowRouter.go "/module/view/#{module_id}"

        'click #delete_module': ->
            console.log 
            if confirm 'delete module?'
                Modules.remove FlowRouter.getParam('module_id')
                FlowRouter.go '/modules'
    
    
    Template.edit_module.helpers
        module: -> Modules.findOne FlowRouter.getParam('module_id')
        
    Template.modules.onCreated ->
        @autorun -> Meteor.subscribe('modules')
    
    
    
    Template.study_module.onCreated ->
        @autorun -> Meteor.subscribe 'module_questions', FlowRouter.getParam('module_id')

    Template.unanswered_question.onCreated ->
        @answered = new ReactiveVar false 
        @answer_id = new ReactiveVar '' 
        @answered_right = new ReactiveVar false
        @answered_wrong = new ReactiveVar false
    
    Template.unanswered_question.helpers
        answers: -> 
            Answers.find
                question_id: @_id
        is_answered: -> Template.instance().answered.get()
        answer_class: -> 
            button_class = ''
            if Template.instance().answer_id.get() is @_id
                if @right then button_class += 'green'
                else if !@right then button_class += 'red'
            if Template.instance().answered.get() is true
                button_class += ' disabled'
            else button_class += 'basic'
            button_class
            
        selected_answer: ->
            Template.instance().answer_id.get() is @_id and Template.instance().answered.get() is true
    
    Template.unanswered_question.events
        'click .pick_answer': (e,t)->
            if @right
                t.answered_right.set true
            else
                t.answered_wrong.set true
            t.answered.set true
            t.answer_id.set @_id

        'click #next': (e,t)->
            console.log 'answered question', t.answer_id.get()
            console.log 'answered right', t.answered_right.get()
            console.log 'answered wrong', t.answered_wrong.get()
            
            if t.answered_right.get()
                Meteor.users.update Meteor.userId(), $addToSet: right_questions: @_id
                Questions.update @_id, $addToSet: right_answerers: Meteor.userId()
            else 
                Meteor.users.update Meteor.userId(), $addToSet: wrong_questions: @_id
                Questions.update @_id, $addToSet: wrong_answerers: Meteor.userId()
            Questions.update @_id, $addToSet: answerers: Meteor.userId()
            

    Template.study_module.helpers
        unanswered_questions: ->
            Questions.find {answerers: $nin: [Meteor.userId()]},
                limit: 1
        
        module: -> Modules.findOne()
        
        answered_all: ->
            answered_module_questions = 
                Questions.find(
                    {answerers: $in: [Meteor.userId()]}).count()
            module_question_count = Questions.find({module_id: FlowRouter.getParam('module_id')}).count()
            console.log 'answered questions', answered_module_questions
            console.log 'total questions', module_question_count
            difference = module_question_count - answered_module_questions
            if difference is 0 then  return true
    
    Template.study_results.helpers
        right_count: -> 
            Questions.find({
                module_id: FlowRouter.getParam('module_id')
                right_answerers: $in: [Meteor.userId()]
                }).count()
        wrong_count: -> 
            Questions.find({
                module_id: FlowRouter.getParam('module_id')
                wrong_answerers: $in: [Meteor.userId()]
                }).count()

    Template.study_results.events
        'click #do_over': ->
            Meteor.call 'do_over', FlowRouter.getParam('module_id')
    
        'click #congrats': ->
            Meteor.users.update Meteor.userId(), $addToSet: completed_modules: FlowRouter.getParam('module_id')
            FlowRouter.go '/courses'
    
    
    Template.module_admin_page.onCreated ->
        @autorun -> Meteor.subscribe 'module', FlowRouter.getParam('module_id')
        @autorun -> Meteor.subscribe 'module_questions', FlowRouter.getParam('module_id')
        @autorun -> Meteor.subscribe 'module_course', FlowRouter.getParam('module_id')

    Template.module_admin_page.helpers
        module_ob: -> 
            Modules.findOne()
    
        questions: ->
            Questions.find
                module_id: FlowRouter.getParam('module_id')
        
    Template.module_admin_page.events
        'click #add_question': ->
            id = Questions.insert
                module_id: FlowRouter.getParam('module_id')

    Template.modules.helpers
        modules: -> 
            Modules.find {}
                
    Template.module_card.helpers
        is_completed: ->
            @_id in Meteor.user().completed_modules

    Template.modules.events
        'click #add_module': ->
            id = Modules.insert {}
            FlowRouter.go "/module/edit/#{id}"


if Meteor.isServer
    Meteor.methods
        do_over: (module_id)->
            Questions.update(
                {},
                {$pull: wrong_answerers: Meteor.userId()},
                multi: true
            )
            Questions.update(
                {},
                {$pull: right_answerers: Meteor.userId()},
                multi: true
            )
            Questions.update(
                {},
                {$pull: answerers: Meteor.userId()},
                multi: true
            )
            return
    
    Modules.allow
        insert: (userId, doc) -> doc.teacher_id is userId
        update: (userId, doc) -> doc.teacher_id is userId or Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> doc.teacher_id is userId or Roles.userIsInRole(userId, 'admin')


    Meteor.publish 'module_course', (module_id)->
        module = Modules.findOne module_id
        Courses.find 
            _id: module.course_id
    
    Meteor.publish 'modules', ()->
        Modules.find {}
    
    Meteor.publish 'module', (id)->
        Modules.find id

    publishComposite 'course_modules', (course_id)->
        {
            find: ->
                Modules.find {course_id: course_id},
                    sort: number: -1
                    # limit: 10
            # children: [
            #     { find: (question) ->
            #         Answers.find { question_id: question._id }
            #     }
            #     {
            #         find: (question) ->
            #             Modules.find { _id: question.module_id } 
            #     }
            # ]
        }

