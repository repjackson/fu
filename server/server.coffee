Meteor.users.allow
    insert: (userId, doc) ->
        # only admin can insert 
        u = Meteor.users.findOne(_id: userId)
        u and u.isAdmin
    update: (userId, doc, fields, modifier) ->
        # console.log 'user ' + userId + 'wants to modify doc' + doc._id
        if userId and doc._id == userId
            # console.log 'user allowed to modify own account!'
            # user can modify own 
            return true
        # admin can modify any
        u = Meteor.users.findOne(_id: userId)
        u and 'admin' in u.roles
    remove: (userId, doc) ->
        # only admin can remove
        u = Meteor.users.findOne(_id: userId)
        u and 'admin' in u.roles



Courses.allow
    insert: (userId, doc) -> doc.teacher_id is userId
    update: (userId, doc) -> doc.teacher_id is userId or Roles.userIsInRole(userId, 'admin')
    remove: (userId, doc) -> doc.teacher_id is userId or Roles.userIsInRole(userId, 'admin')




Meteor.publish 'courses', (selected_tags, filter, limit)->

    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    Courses.find match

Meteor.publish 'course', (id)->
    Courses.find id



Meteor.publish 'tags', (selected_tags, filter)->
    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    if filter then match.type = filter

    cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    # console.log 'filter: ', filter
    # console.log 'cloud: ', cloud

    cloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()
