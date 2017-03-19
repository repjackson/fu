Template.product_page.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')



Template.product_page.helpers
    product: ->
        Docs.findOne FlowRouter.getParam('doc_id')


Template.product_page.events
    'click .edit_product': ->
        FlowRouter.go "/product/edit/#{@_id}"
