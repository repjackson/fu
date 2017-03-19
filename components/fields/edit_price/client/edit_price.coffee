Template.edit_price.events
    'change #price': ->
        doc_id = FlowRouter.getParam('doc_id')
        price = parseInt $('#price').val()

        Docs.update doc_id,
            $set: price: price