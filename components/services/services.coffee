FlowRouter.route '/services', action: (params) ->
    BlazeLayout.render 'layout',
        # cloud: 'cloud'
        main: 'services'
