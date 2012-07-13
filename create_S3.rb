require 'aws-sdk'

s3 = AWS::S3.new(:access_key_id     => 'XXACCESS_KEY_IDXX',
                 :secret_access_key => 'XXSECRET_ACCESS_KEYXX')

uploader000 = s3.buckets.create('your_bucket')
uploader000.objects['this/is/not/a/directry/tmp.txt'].write "this is not a directry"
