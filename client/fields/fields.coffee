Template.subtitle.events
    'blur #subtitle': ->
        subtitle = $('#subtitle').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: subtitle: subtitle
            
            
Template.tags.events
    'keydown #add_tag': (e,t)->
        if e.which is 13
            doc_id = FlowRouter.getParam('doc_id')
            tag = $('#add_tag').val().toLowerCase().trim()
            if tag.length > 0
                Docs.update doc_id,
                    $addToSet: tags: tag
                $('#add_tag').val('')

    'click .doc_tag': (e,t)->
        tag = @valueOf()
        Docs.update FlowRouter.getParam('doc_id'),
            $pull: tags: tag
        $('#add_tag').val(tag)



Template.price.events
    'change #price': ->
        doc_id = FlowRouter.getParam('doc_id')
        price = parseInt $('#price').val()

        Docs.update doc_id,
            $set: price: price
            
            
            
Template.title.events
    'blur #title': ->
        title = $('#title').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: title: title
            
            
Template.link.events
    'blur #link': ->
        link = $('#link').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: link: link
            
            
            
Template.name.events
    'blur #name': ->
        name = $('#name').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: name: name
            
            
            
            
Template.type.events
    'blur #type': ->
        type = $('#type').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: type: type