#!/usr/bin/env ruby

require 'oauth2'

APP_ID = 'b72156195338939a8a0ccd6628d4d30584b2a2f7b0303555c988149319a5285a'
SECRET = '8fdb306ac247952a8804ab8fe393eaf8c8c18328d42442bfee01c79ac1f07786'
URL = 'http://making.dev'
CALLBACK_URL = 'http://making.dev/api/v1/oauth/default_callback'

client = OAuth2::Client.new(APP_ID, SECRET, site: URL)

