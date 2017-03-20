@selected_tags = new ReactiveArray []

Template.course_cloud.onCreated ->
    @autorun -> Meteor.subscribe('tags', selected_tags.array())

Template.course_cloud.helpers
    all_tags: ->
        course_count = Courses.find().count()
        if 0 < course_count < 3 then Tags.find { count: $lt: course_count } else Tags.find()

    settings: -> {
        position: 'bottom'
        limit: 10
        rules: [
            {
                collection: Tags
                field: 'name'
                matchAll: true
                template: Template.tag_result
            }
            ]
    }
    

    selected_tags: -> 
        # type = 'event'
        # console.log "selected_#{type}_tags"
        selected_tags.array()


Template.course_cloud.events
    'click .select_tag': -> selected_tags.push @name
    'click .unselect_tag': -> selected_tags.remove @valueOf()
    'click #clear_tags': -> selected_tags.clear()
    
    'keyup #search': (e,t)->
        e.preventDefault()
        val = $('#search').val().toLowerCase().trim()
        switch e.which
            when 13 #enter
                switch val
                    when 'clear'
                        selected_tags.clear()
                        $('#search').val ''
                    else
                        unless val.length is 0
                            selected_tags.push val.toString()
                            $('#search').val ''
            when 8
                if val.length is 0
                    selected_tags.pop()
                    
    'autocompleteselect #search': (event, template, doc) ->
        # console.log 'selected ', doc
        selected_tags.push doc.name
        $('#search').val ''
