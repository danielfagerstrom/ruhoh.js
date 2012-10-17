define [
  "cs!utils/log"
  "markdown"
  "yaml"
], (Log, Markdown) ->
  
  # Matcher for YAML Front Matter
  FMregex: /^---\n(.|\n)*---\n/
  
  # Parse and store the YAML Front Matter from the file.
  frontMatter: (content, file) ->
    front_matter = @FMregex.exec(content)
    Log.parseError file, "Invalid YAML Front Matter"  unless front_matter
    front_matter = front_matter[0].replace(/---\n/g, "")
    jsyaml.load(front_matter) or {}

  # Internal: Parse content from a file.
  # Content in a file is everything below the Front Matter.
  # 
  #  content - Required [String] The file contents.
  #  id      - Optional [String] The file id which is the name.
  #            File extension determines parse method.
  #
  # Returns: [String] The parsed content.
  content: (content, id) ->
    content = content.replace(@FMregex, "")
    if id and ["md", "markdown"].indexOf(id.split(".").pop().toLowerCase()) isnt -1
      converter = new Markdown.Converter()
      return converter.makeHtml(content)
    content
