require 'time'
require 'openssl'
require 'base64'
require 'cgi'
require 'net/http'
require 'uri'

Net::HTTP.version_1_2

BUKET_NAME = 'bucket_name'
BUCKET_PATH = '/'
ACCESS_KEY_ID = 'access_key_id'
SECRET_ACCESS_KEY = 'secret_access_key_id'
DATE = Time.now.rfc2822

def aws_sign(secret_access_key_id, date, bucket, path)
  string_to_sign = "GET\n\n\n#{date}\n/#{bucket}#{path}"
  digest = OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, secret_access_key_id, string_to_sign)
  Base64.encode64(digest).strip
end

signature = aws_sign(SECRET_ACCESS_KEY, DATE, BUKET_NAME, BUCKET_PATH)
signature = URI.escape(signature)
header = {
    'Host' => 's3.amazonaws.com',
    'Date' => DATE,
    'Authorization' => "AWS #{ACCESS_KEY_ID}:#{signature}"}

content = nil
Net::HTTP.start(BUKET_NAME + '.' + header['Host']) do |http|
  content = http.get("/", header)
end

# for debug
content.body
