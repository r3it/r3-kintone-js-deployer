
# ------------------------------------------------------------------------

require File.expand_path("deployfile.rb")

require 'net/http'
require 'net/http/post/multipart' # gem install multipart-post
require 'openssl'
require 'base64'
require 'json'

class Kintone
  # KINTONE_USERNAME / KINTONE_PASSWORD
  require File.expand_path(".kintone.rb")

  def initialize
    @http = Net::HTTP.new("#{KINTONE_SUBDOMAIN}.cybozu.com",443)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    @auth = Base64.strict_encode64("#{KINTONE_USERNAME}:#{KINTONE_PASSWORD}")
  end

  def send_request(request)
    puts "kintone request: #{request.method} #{request.path}"
    @http.start do |h|
      request['X-Cybozu-Authorization'] = @auth

      response = h.request(request)

      puts "kintone response: #{response.code}"
      puts response.body
      JSON.parse(response.body)
    end
  end

  def send_request_body(request,body)
    request['content-type'] = 'application/json'
    request.body = body.to_json
    puts request.body 
    send_request request
  end

  def put_file(file_path, content_type)
    if file_path =~ /^(http|https):\/\//
      puts "#{file_path} is URL" 
      return { type:"URL", url: file_path }
    end

    puts "putting file: #{file_path}" 
    upload_file = UploadIO.new File.new(file_path), content_type, File.basename(file_path)
    request = Net::HTTP::Post::Multipart.new "/k/v1/file.json","file" => upload_file

    response = send_request request

    { type:"FILE", file: { fileKey: response["fileKey"] } }
  end

  def put_customize(customize)
    puts "put customize: #{customize[:app]}" 
    request = Net::HTTP::Put.new("/k/v1/preview/app/customize.json")

    response = send_request_body request, customize
    
    response["revision"]
  end

  def start_apps(apps)
    puts "start apps: #{apps}" 
    request = Net::HTTP::Post.new("/k/v1/preview/app/deploy.json")
    
    response = send_request_body request, { apps: apps.map{|a| {app: a} } }
    
    response["revision"]
  end
  
end

puts "...::: kintone deploy script :::..."
puts "environment: #{DEPLOY_ENV}"

def deploy kintone, app_name, files
  app = APP_IDS[app_name][DEPLOY_ENV]
  puts "deploy #{app_name}/#{app}"

  customize = { 
    app: app, 
    scope: "ALL",
    desktop: {
      js: [], css: []
    },
    # mobile は非対応
  }

  js = customize[:desktop][:js]
  files[:js].each do |file_path|
    js << kintone.put_file(file_path,"application/javascript")
  end

  css = customize[:desktop][:css]
  files[:css].each do |file_path|
    css << kintone.put_file(file_path,"text/css")
  end

  new_revision = kintone.put_customize customize
  puts "new revision: #{new_revision}"

  app
end

kintone = Kintone.new

# ruby 1.9 からは Hash の追加順序で列挙される。
apps = []
if ARGV.length == 2
  app_name = ARGV[1].to_sym
  files =   DEPLOY_FILES[app_name]
  apps << deploy(kintone, app_name, files)
else
  DEPLOY_FILES.each do |app_name,files|
    apps << deploy(kintone, app_name, files)
  end
end
kintone.start_apps apps