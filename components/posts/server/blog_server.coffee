Meteor.publish 'featured_posts', ->
    Docs.find {
        featured: true
        type: 'post'
        }, sort: publish_date: -1
        

Meteor.publish 'selected_posts', (selected_post_tags)->
    
    self = @
    match = {}
    if selected_post_tags.length > 0 then match.tags = $all: selected_post_tags
    match.type = 'post'
    if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        match.published = true
    

    Docs.find match,
        limit: 10
        sort: 
            publish_date: -1


Meteor.publish 'post', (doc_id)->
    Docs.find doc_id

    
