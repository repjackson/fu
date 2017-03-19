db.docs.find({"authorId": {$exists: true}}).forEach(function(item)
{
        item.author_id = "vyqyHFRZG4CpogTAG";
        db.docs.save(item);
})


db.docs.find({"type": {$exists: false}}).forEach(function(item)
{
        item.type = "post";
        db.docs.save(item);
})


db.docs.update( { }, { $rename: { 'body': 'content' } }, { multi: true} )




db.docs.update({
            }, {
                $set: {
                    "tag_count": 
                }
            },
            function(err) {
                if (err) console.log(err);
            }
        );
    })


db.docs.find({}).forEach(
    function(doc) {
        var tag_count = doc.tags.length;
        doc.tag_count = tag_count;
        db.docs.save(doc);
    }
)


"MONGO_URL": "mongodb://facetadmin:Turnf34ragainst!@aws-us-east-1-portal.21.dblayer.com:10444/facet?ssl=true",


mongo --ssl --sslAllowInvalidCertificates aws-us-east-1-portal.21.dblayer.com:10444/facet -u facetadmin -pTurnf34ragainst!

DEPLOY_HOSTNAME=us-east-1.galaxy-deploy.meteor.com meteor deploy --settings settings.json www.facet.cloud


notes
    any kind of app, build examples of everything
    service marketplace, anyone can make money
    learn, prove it, gain reputation, add service, support life