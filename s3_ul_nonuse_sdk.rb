require 'time'
require 'openssl'
require 'base64'
require 'cgi'
require 'net/http'
require 'uri'

Net::HTTP.version_1_2

AWS_PORT = 443
S3_END_POINT = 's3-ap-northeast-1.amazonaws.com'
BUKET_NAME = 'bucket_name'
OBJECT_PATH = '/object_path'
ACCESS_KEY_ID = 'access_key_id'
SECRET_ACCESS_KEY = 'secret_access_key_id'
DATE = Time.now.rfc822

def authorized_header(header, object_path)
  signature = signature(SECRET_ACCESS_KEY, string_to_sign(header['date'], object_path))
  header['authorization'] = "AWS #{ACCESS_KEY_ID}:#{URI.escape(signature)}"
  header
end

def string_to_sign(date, path)
  [ 'PUT',
    "\ntext/plain",
    date,
    "x-amz-acl:private\nx-amz-storage-class:REDUCED_REDUNDANCY",
    "/#{BUKET_NAME}#{path}" ].join("\n")
end

def signature(secret, string_to_sign)
  hmac_digest = OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, secret, string_to_sign)
  Base64.encode64(hmac_digest).strip
end

header = { 'content-type'        => 'text/plain',
           'date'                => Time.now.rfc822,
           'x-amz-acl'           => 'private',
           'x-amz-storage-class' => 'REDUCED_REDUNDANCY' }

content = nil
https = Net::HTTP.new("#{BUKET_NAME}.#{S3_END_POINT}", AWS_PORT)
https.use_ssl = true
data = "this is a sample code ;)"
response = https.put(OBJECT_PATH, data, authorized_header(header, OBJECT_PATH))

## for debug
puts "response code:  #{response.code} "
