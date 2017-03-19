Template.edit_product.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')

Template.edit_product.helpers
    product: ->
        Docs.findOne FlowRouter.getParam('doc_id')
    
        
Template.edit_product.events
    'click #save_product': ->
        FlowRouter.go "/product/view/#{@_id}"