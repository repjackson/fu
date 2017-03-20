
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

FlowRouter.route '/module/view/:module_id', action: (params) ->
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
                
    

    Template.modules.events
        'click #add_module': ->
            id = Modules.insert {}
            FlowRouter.go "/module/edit/#{id}"


if Meteor.isServer
    Modules.allow
        insert: (userId, doc) -> doc.teacher_id is userId
        update: (userId, doc) -> doc.teacher_id is userId or Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> doc.teacher_id is userId or Roles.userIsInRole(userId, 'admin')


    Meteor.publish 'module_questions', (module_id)->
        Questions.find 
            module_id: module_id
    
    Meteor.publish 'module_course', (module_id)->
        module = Modules.findOne module_id
        Courses.find 
            _id: module.course_id
    
    Meteor.publish 'modules', ()->
        Modules.find {}
    
    Meteor.publish 'module', (id)->
        Modules.find id

