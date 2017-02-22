
Template.content.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'all_docs'


Template.content.helpers
    docs: -> Docs.find()



Template.content.events
    'click #add_page': ->
        id = Docs.insert 
            type: 'page'
        FlowRouter.go "/page/edit/#{id}"

    'click #add_doc': ->
        id = Docs.insert({})
        FlowRouter.go "/edit/#{id}"
