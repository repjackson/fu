if Meteor.isClient
    Template.slider.onCreated ->
        @autorun -> Meteor.subscribe 'slides'
    
    
    
    Template.slider.onRendered ->
        Meteor.setTimeout (->
            $('#layerslider').layerSlider
                autoStart: true
                # firstLayer: 1
                # skin: 'borderlesslight'
                # skinsPath: '/static/layerslider/skins/'
            ), 1000
        
            # console.log 'ready'
    
    
    Template.slider.helpers
        slides: -> 
            Docs.find {
                type: 'slide'
                },
                sort: order: 1
            
if Meteor.isServer
    Meteor.publish 'slides', ->
        Docs.find 
            type: 'slide'
