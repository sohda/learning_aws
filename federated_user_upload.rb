require 'aws-sdk'

if ARGV.size < 2
  puts <<-USAGE
usage:
  ruby federated_user_upload.rb [bucket name] [object key]
  USAGE
  exit
end

sts = AWS::STS.new(:access_key_id     => 'your_access_key_id',
                   :secret_access_key => 'your_secret_access_key')

bucket_name = ARGV[0]
object_key = ARGV[1]

policy = AWS::STS::Policy.new
policy.allow(:actions   => ['s3:PutObject'],
             :resources => "arn:aws:s3:::#{bucket_name}/*")
session = sts.new_federated_session('FederatedUserOne',
                                    :policy   => policy,
                                    :duration => 3600)

s3 = AWS::S3.new(:access_key_id     => session.credentials[:access_key_id],
                 :secret_access_key => session.credentials[:secret_access_key],
                 :logger            => Logger.new($stdout),
                 :log_level         => :debug,
                 :session_token     => session.credentials[:session_token])
s3.buckets[bucket_name].objects[object_key].write "congrachuration!"

#this request must be 'AWS::S3::Errors::AccessDenied: Access Denied'
s3.buckets[bucket_name].objects[object_key].read

sleep 3600
#this 'AWS::S3::Errors::ExpiredToken: The provided token has expired.'
s3.buckets[bucket_name].objects[object_key].write "congrachuration!"
