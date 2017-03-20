
@Courses = new Meteor.Collection 'courses'

Courses.before.insert (userId, doc)->
    doc.teacher_id = Meteor.userId()
    return


FlowRouter.route '/courses', action: ->
    BlazeLayout.render 'layout', 
        main: 'courses'

FlowRouter.route '/course/edit/:course_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_course'

FlowRouter.route '/course/view/:course_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'course_page'



if Meteor.isClient
    Template.edit_course.onCreated ->
        @autorun -> Meteor.subscribe 'course', FlowRouter.getParam('course_id')
    
    Template.edit_course.events
        'keydown #add_tag': (e,t)->
            if e.which is 13
                course_id = FlowRouter.getParam('course_id')
                tag = $('#add_tag').val().toLowerCase().trim()
                if tag.length > 0
                    Courses.update course_id,
                        $addToSet: tags: tag
                    $('#add_tag').val('')
    
        'click .doc_tag': (e,t)->
            tag = @valueOf()
            Courses.update FlowRouter.getParam('course_id'),
                $pull: tags: tag
            $('#add_tag').val(tag)

    
        'click #save_course': ->
            title = $('#title').val()
            course_id = FlowRouter.getParam('course_id')

            Courses.update course_id,
                $set: title: title
                , ->
                    FlowRouter.go "/course/view/#{course_id}"

        'click #delete_course': ->
            if confirm 'delete course?'
                Courses.remove FlowRouter.getParam('course_id')
                FlowRouter.go '/courses'
    
    
    Template.edit_course.helpers
        course: -> Courses.findOne FlowRouter.getParam('course_id')
        
    Template.courses.onCreated ->
        @autorun -> Meteor.subscribe('courses', selected_tags.array())
    
    
    
    
    Template.course_page.onCreated ->
        @autorun -> Meteor.subscribe 'course', FlowRouter.getParam('course_id')
        @autorun -> Meteor.subscribe 'course_sections', FlowRouter.getParam('course_id')
    
    Template.course_page.helpers
        course_ob: -> 
            Courses.findOne()
    
        sections: ->
            Sections.find
                course_id: FlowRouter.getParam('course_id')
        
    Template.course_page.events
        'click #add_section': ->
            id = Sections.insert
                course_id: FlowRouter.getParam('course_id')
            FlowRouter.go "/section/edit/#{id}"
    
    Template.courses.helpers
        courses: -> 
            Courses.find {}
                
    

    Template.courses.events
        'click #add_course': ->
            id = Courses.insert {}
            FlowRouter.go "/course/edit/#{id}"


if Meteor.isServer
    Courses.allow
        insert: (userId, doc) -> doc.teacher_id is userId
        update: (userId, doc) -> doc.teacher_id is userId or Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> doc.teacher_id is userId or Roles.userIsInRole(userId, 'admin')


    Meteor.publish 'course_sections', (course_id)->
        Sections.find 
            course_id: course_id
    
    Meteor.publish 'courses', (selected_tags, filter, limit)->
    
        self = @
        match = {}
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        Courses.find match
    
    Meteor.publish 'course', (id)->
        Courses.find id

