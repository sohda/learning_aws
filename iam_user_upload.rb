require 'aws-sdk'

if ARGV.size < 2
  puts <<-USAGE
usage:
  ruby iam_user_upload.rb [bucket name] [object key]
  USAGE
  exit
end

iam = AWS::IAM.new
user = iam.users.create('uploader')
group = iam.groups.create('uploaders')


bucket_name = ARGV[0]
object_key = ARGV[1]

policy = AWS::IAM::Policy.new do |p|
           p.allow(:actions => ['s3:PutObject'],
                   :resources => "arn:aws:s3:::#{bucket_name}/*",
                   :principals => :any)
         end

group.policies["UploadOnly"] = policy
group.users.add(user)

access_key = user.access_keys.create
secrets = access_key.credentials
s3 = AWS::S3.new(:access_key_id     => secrets[:access_key_id],
                 :secret_access_key => secrets[:secret_access_key])

#if do not sleep, return response such as
#  'The AWS Access Key Id you provided does not exist in our records.'
sleep 7

s3.buckets[bucket_name].objects[object_key].write "congrachration!"

#read action must be not success
#because set readonly policy
s3.buckets[bucket_name].objects[object_key].read
