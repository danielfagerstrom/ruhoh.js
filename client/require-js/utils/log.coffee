define [
  "jquery"
  "underscore"
], ($, _) ->
  
  # Public: Respond when a file fails to load.
  # Returns: Throws Exception.
  loadError: (model, jqxhr) ->
    message = jqxhr.status + ": " + jqxhr.statusText
    @render model.url, message, "Load Error"
    throw (message + ": " + model.url)

  # Public: Respond when a file cannot be parsed
  # usually because the file is not formatted properly.
  # Returns: Throws Exception.
  parseError: (fileId, message) ->
    @render fileId, message, "Parse Error"
    throw (message)

  configError: (message) ->
    @render "config.yml", message, "Configuration Error"
    throw (message)
  
  # Public: Render a user friendly message into the DOM.
  # Returns: Nothing.
  render: (fileId, message, type) ->
    $("body").html "<h2 style=\"color:red\">" + type + ": " + message + "</h2>" + "<h3>File: " + fileId + "</h3>"
