require 'uri'
require 'json'

module Jekyll
  module Filters
    # Convert a Textile string into HTML output.
    #
    # input - The Textile String to convert.
    #
    # Returns the HTML formatted String.
    def textilize(input)
      site = @context.registers[:site]
      converter = site.getConverterImpl(Jekyll::Converters::Textile)
      converter.convert(input)
    end

    # Convert a Markdown string into HTML output.
    #
    # input - The Markdown String to convert.
    #
    # Returns the HTML formatted String.
    def markdownify(input)
      site = @context.registers[:site]
      converter = site.getConverterImpl(Jekyll::Converters::Markdown)
      converter.convert(input)
    end

    # Format a date in short format e.g. "27 Jan 2011".
    #
    # date - the Time to format.
    #
    # Returns the formatting String.
    def date_to_string(date)
      time(date).strftime("%d %b %Y")
    end

    # Format a date in long format e.g. "27 January 2011".
    #
    # date - The Time to format.
    #
    # Returns the formatted String.
    def date_to_long_string(date)
      time(date).strftime("%d %B %Y")
    end

    # Format a date for use in XML.
    #
    # date - The Time to format.
    #
    # Examples
    #
    #   date_to_xmlschema(Time.now)
    #   # => "2011-04-24T20:34:46+08:00"
    #
    # Returns the formatted String.
    def date_to_xmlschema(date)
      time(date).xmlschema
    end

    # Format a date according to RFC-822
    #
    # date - The Time to format.
    #
    # Examples
    #
    #   date_to_rfc822(Time.now)
    #   # => "Sun, 24 Apr 2011 12:34:46 +0000"
    #
    # Returns the formatted String.
    def date_to_rfc822(date)
      time(date).rfc822
    end

    # XML escape a string for use. Replaces any special characters with
    # appropriate HTML entity replacements.
    #
    # input - The String to escape.
    #
    # Examples
    #
    #   xml_escape('foo "bar" <baz>')
    #   # => "foo &quot;bar&quot; &lt;baz&gt;"
    #
    # Returns the escaped String.
    def xml_escape(input)
      CGI.escapeHTML(input.to_s)
    end

    # CGI escape a string for use in a URL. Replaces any special characters
    # with appropriate %XX replacements.
    #
    # input - The String to escape.
    #
    # Examples
    #
    #   cgi_escape('foo,bar;baz?')
    #   # => "foo%2Cbar%3Bbaz%3F"
    #
    # Returns the escaped String.
    def cgi_escape(input)
      CGI::escape(input)
    end

    # URI escape a string.
    #
    # input - The String to escape.
    #
    # Examples
    #
    #   uri_escape('foo, bar \\baz?')
    #   # => "foo,%20bar%20%5Cbaz?"
    #
    # Returns the escaped String.
    def uri_escape(input)
      URI.escape(input)
    end

    # Count the number of words in the input string.
    #
    # input - The String on which to operate.
    #
    # Returns the Integer word count.
    def number_of_words(input)
      input.split.length
    end

    # Join an array of things into a string by separating with commas and the
    # word "and" for the last one.
    #
    # array - The Array of Strings to join.
    #
    # Examples
    #
    #   array_to_sentence_string(["apples", "oranges", "grapes"])
    #   # => "apples, oranges, and grapes"
    #
    # Returns the formatted String.
    def array_to_sentence_string(array)
      connector = "and"
      case array.length
      when 0
        ""
      when 1
        array[0].to_s
      when 2
        "#{array[0]} #{connector} #{array[1]}"
      else
        "#{array[0...-1].join(', ')}, #{connector} #{array[-1]}"
      end
    end

    # Convert the input into json string
    #
    # input - The Array or Hash to be converted
    #
    # Returns the converted json string
    def jsonify(input)
      input.to_json
    end

    # Group an array of items by a property
    #
    # input - the inputted Enumerable
    # property - the property
    #
    # Returns an array of Hashes, each looking something like this:
    #  {"name"  => "larry"
    #   "items" => [...] } # all the items where `property` == "larry"
    def group_by(input, property)
      if groupable?(input)
        input.group_by do |item|
          item_property(item, property).to_s
        end.inject([]) do |memo, i|
          memo << {"name" => i.first, "items" => i.last}
        end
      else
        input
      end
    end

    # Filter an array of objects
    #
    # input - the object array
    # key - key within each object to filter by
    # value - desired value
    #
    # Returns the filtered array of objects
    def where(input, key, value)
      return input unless input.is_a?(Array)
      input.select { |object| object[key] == value }
    end

    private
    def time(input)
      case input
      when Time
        input
      when String
        Time.parse(input)
      else
        Jekyll.logger.error "Invalid Date:", "'#{input}' is not a valid datetime."
        exit(1)
      end
    end

    def groupable?(element)
      element.respond_to?(:group_by)
    end

    def item_property(item, property)
      if item.respond_to?(:data)
        item.data[property.to_s]
      else
        item[property.to_s]
      end
    end
  end
end
