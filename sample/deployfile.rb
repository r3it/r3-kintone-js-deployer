#--------------------------------------------
# js/css deploy settings
#--------------------------------------------
DEPLOY_ENV = (ARGV[0] || 'dev').to_sym

APP_ID_FILE = "src/appID_#{DEPLOY_ENV}.js"

APP_IDS = {
  A: { dev: 88, prod: 88 },
  B: { dev: 89, prod: 89 },
  C: { dev: 90, prod: 90 },
  D: { dev: 91, prod: 91 },
  E: { dev: 92, prod: 92 },
  F: { dev: 93, prod: 93 },
}

DEPLOY_FILES = {
  A: {
    js: [ "lib/libs.js", APP_ID_FILE, "src/A.js" ],
    css: [ 
      "bower_components/handsontable/dist/handsontable.full.min.css",
      "bower_components/sweetalert/dist/sweetalert.css",
      "src/51-us-default.css",
      "src/handsontable.fix.css",
      ]
  },
  B: {
    js: [ APP_ID_FILE, "src/B.js" ],
    css: []
  },
  C: {
    js: [ APP_ID_FILE, "src/C.js" ],
    css: []
  },
  D: {
    js: [ APP_ID_FILE, "src/D.js" ],
    css: []
  },
  E: {
    js: [ "lib/libs.js", APP_ID_FILE, "src/E.js" ],
    css: [ 
      "bower_components/handsontable/dist/handsontable.full.min.css",
      "src/handsontable.fix.css",
      ]
  },
  F: {
    js: [ "src/F.js" ],
    css: []
  },
}

KINTONE_SUBDOMAIN = 'r3it-other' 
# dev と prod でドメインを切り替えたい場合のサンプル
#KINTONE_SUBDOMAIN = { dev:'r3it', prod:'r3it-other' }[DEPLOY_ENV]
