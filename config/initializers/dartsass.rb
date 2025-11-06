# Configure dartsass-rails to compile multiple SCSS files
Rails.application.config.dartsass.builds = {
  "application.scss" => "application.css",
  "desktop.scss" => "desktop.css"
}
