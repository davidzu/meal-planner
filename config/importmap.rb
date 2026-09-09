# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/stimulus", to: "vendor/javascript/@hotwired/stimulus.js", preload: true
pin "@hotwired/turbo-rails", to: "vendor/javascript/@hotwired/turbo-rails.js", preload: true
pin "@hotwired/turbo", to: "vendor/javascript/@hotwired/turbo.js", preload: true
pin "@rails/actioncable/src", to: "vendor/javascript/@rails/actioncable/src.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"