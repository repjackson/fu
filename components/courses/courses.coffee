
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
    
    Template.edit_course.helpers
        course: -> Courses.findOne FlowRouter.getParam('course_id')
        
    Template.courses.onCreated ->
        @autorun -> Meteor.subscribe('courses', selected_tags.array())
    
    
    Template.course_page.onCreated ->
        @autorun -> Meteor.subscribe 'course', FlowRouter.getParam('course_id')
    
    
    
    Template.course_page.helpers
        course: -> Courses.findOne FlowRouter.getParam('course_id')
    
    
    
    Template.courses.helpers
        courses: -> 
            Courses.find {}
                
        sections: ->
            Sections.find
                course_id: FlowRouter.getParam('course_id')
    
