db.docs.find({"authorId": {$exists: true}}).forEach(function(item)
{
        item.author_id = "vyqyHFRZG4CpogTAG";
        db.docs.save(item);
})


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


mongo --ssl --sslAllowInvalidCertificates aws-us-east-1-portal.21.dblayer.com:10444/facetdb -u <user> -p<password>


DEPLOY_HOSTNAME=us-east-1.galaxy-deploy.meteor.com meteor deploy --settings settings.json www.facet.enterprises


notes
    any kind of app, build examples of everything
    service marketplace, anyone can make money
    learn shit, prove it, add service, build business