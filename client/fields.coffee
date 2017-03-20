
Template.content.events
    'blur .froala-container': (e,t)->
        html = t.$('div.froala-reactive-meteorized-override').froalaEditor('html.get', true)
        
        course_id = FlowRouter.getParam('course_id')

        Courses.update course_id,
            $set: 
                content: html



Template.content.helpers
    getFEContext: ->
        @current_doc = Courses.findOne FlowRouter.getParam('course_id')
        self = @
        {
            _value: self.current_doc.content
            _keepMarkers: true
            _className: 'froala-reactive-meteorized-override'
            toolbarInline: false
            initOnClick: false
            imageInsertButtons: ['imageBack', '|', 'imageByURL']
            tabSpaces: false
            height: 300
            '_onsave.before': (e, editor) ->
                # Get edited HTML from Froala-Editor
                newHTML = editor.html.get(true)
                # Do something to update the edited value provided by the Froala-Editor plugin, if it has changed:
                if !_.isEqual(newHTML, self.current_doc.content)
                    # console.log 'onSave HTML is :' + newHTML
                    Courses.update { _id: self.current_doc._id }, $set: content: newHTML
                false
                # Stop Froala Editor from POSTing to the Save URL
        }
