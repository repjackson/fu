FlowRouter.route '/courses', action: ->
    BlazeLayout.render 'layout', 
        main: 'courses'

FlowRouter.route '/course/edit/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_course'

FlowRouter.route '/course/view/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'course_page'



if Meteor.isClient
    
    Template.edit_course.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.edit_course.helpers
        course: -> Docs.findOne FlowRouter.getParam('doc_id')
        
    Template.courses.onCreated ->
        @autorun -> Meteor.subscribe('selected_courses', selected_tags.array())
    
    
    Template.course_page.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    
    
    Template.course_page.helpers
        course: ->
            Docs.findOne FlowRouter.getParam('doc_id')
    
    
    Template.course_page.events
        'click .edit_course': ->
            FlowRouter.go "/course/edit/#{@_id}"
    
    
    
    
    Template.courses.helpers
        courses: -> 
            Docs.find {
                type: 'course'
                }
                
    Template.courses.events
        'click #add_course': ->
            id = Docs.insert
                type: 'course'
            FlowRouter.go "/course/edit/#{id}"
    
    
    
    
    
        
    Template.course_item.helpers
        tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'
    
        can_edit: -> @author_id is Meteor.userId()
    
        


    Template.course_item.events
        'click .course_tag': ->
            if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()
    
        'click .edit_course': ->
            FlowRouter.go "/course/edit/#{@_id}"


if Meteor.isServer
    Meteor.publish 'selected_courses', (selected_course_tags)->
        
        self = @
        match = {}
        if selected_course_tags.length > 0 then match.tags = $all: selected_course_tags
        match.type = 'course'
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        
    
        Docs.find match
    
    Meteor.publish 'course', (doc_id)->
        Docs.find doc_id
    
        
