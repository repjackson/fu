FlowRouter.route '/posts', action: ->
    BlazeLayout.render 'layout', 
        main: 'posts'

FlowRouter.route '/post/edit/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_post'

FlowRouter.route '/post/view/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'post_page'







if Meteor.isClient
    Template.posts.onCreated ->
        @autorun -> Meteor.subscribe('selected_posts', selected_tags.array())
    
    Template.posts.onRendered ->
        $('#blog_slider').layerSlider
            autoStart: true
    
    
    Template.posts.helpers
        posts: -> 
            Docs.find {
                type: 'post'
                },
                limit: 1
                
    Template.posts.events
        'click #add_post': ->
            id = Docs.insert
                type: 'post'
            FlowRouter.go "/post/edit/#{id}"
    
    
    
    
    
        
    Template.post_item.helpers
        tag_class: -> if @valueOf() in selected_tags.array() then 'secondary' else 'basic'
    
        can_edit: -> @author_id is Meteor.userId()
    
        
    
    
    Template.post_item.events
        'click .post_tag': ->
            if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()
    
        'click .edit_post': ->
            FlowRouter.go "/post/edit/#{@_id}"



if Meteor.isServer
    Meteor.publish 'selected_posts', (selected_post_tags)->
        
        self = @
        match = {}
        match.tags = $all: selected_post_tags
        match.type = 'post'
        if not @userId or not Roles.userIsInRole(@userId, ['admin'])
            match.published = true
        
    
        Docs.find match,
            limit: 3
    
    
    Meteor.publish 'post', (doc_id)->
        Docs.find doc_id
    
        
