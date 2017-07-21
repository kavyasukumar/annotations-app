require 'nokogiri'
require 'sanitize'
require 'fastimage'

module DocumentHelpers
  def doc_markup
    set_annotators
    @document_obj = sanitize_doc(data.doc)
    @markup = parse_doc
    @markup
  end

  private
  def counter(key = 'default')
    @_counters ||= ActiveSupport::HashWithIndifferentAccess.new
    if @_counters[key].nil?
      @_counters[key] = 0
    else
      @_counters[key] += 1
    end
  end

  def set_annotators
    @annotators_hash = {}
    data.annotators.each do |person|
      person['initials'] = person['initials'].strip
      person['name'] = person['name'].strip
    end
    @annotators_hash = Hash[data.annotators.map { |person| [person['initials'], person] }]
  end

  def sanitize_doc(content)
    body = Nokogiri::HTML::DocumentFragment.parse(content.gsub(/(?:<br>)/, '</p><p>'))
    body.search('meta, style, sup').remove

    sanitized_html = Sanitize.fragment(body.to_html, Sanitize::Config::BASIC)
    sanitized_html.gsub!('［','[')
    sanitized_html.gsub!('］', ']')

    # filter to only p tags
    doc_obj = Nokogiri::HTML::DocumentFragment.parse(sanitized_html)
    doc_obj.children.each do |node|
      node.remove unless node.name == 'p'
      next unless node.name == 'p'
      node.remove if node.text.strip.empty?
    end
    doc_obj
  end

  def process_images(node)
    inner_text(node).scan(/(http[s]?:\/?\/?[^\s]*.jpg)[^\,]*(,\s(.*))?/) do |matches|
      image_data = {}
      image_data['url'] = matches[0]
      image_data['credit'] = matches[2]
      dimensions = FastImage.size(matches[0])
      image_data['width'] = dimensions[0].to_i
      image_data['height'] = dimensions[1].to_i
      @platform_output += partial('partials/_img_tag',
                                  :locals => { :value => image_data })
      return true
    end
    false
  end

  def process_annotations(node, index)
    inner_text(node).scan(/(\[(..)\s*:\s*)(.*)/) do |matches|
      initials = matches[1]
      nodes = []
      nodes.push(node)
      counter('p_tags')

      # find end of annotations
      while @document_obj.children[index + @skip_next].text.strip[-1] != ']'
        @skip_next += 1
        counter('p_tags')
        nodes.push(@document_obj.children[index + @skip_next])
      end
      annotation_text = ''
      nodes.each do |annotation_p_node|
        annotation_text += annotation_p_node.to_html.sub(matches[0], '').sub(']', '')
      end
      @annotation_text_count += 1
      @platform_output += partial('partials/annotation',
                                  :locals => { :value => annotation_text,
                                               :person => @annotators_hash[initials],
                                               :initials => initials,
                                               :total_count => @annotation_count,
                                               :this_index => @annotation_text_count })
      return true
    end
    false
  end

  def process_highlights(node)
    loop_again = true
    @annotation_count = 0
    @annotation_text_count = 0

    text = inner_text(node)
    while loop_again
      loop_again = false
      matched_text = nil
      rendered_highlight = nil
      text.scan(/[^\[]*(\[\[([^\]]*)\]\]).*/) do |matches|
        loop_again = true
        @annotation_count += 1
        rendered_highlight = partial('partials/_highlight',
                                     :locals => { :value => matches[1],
                                                  :count => @annotation_count })
        matched_text = matches[0]
      end
      text = text.gsub(matched_text, rendered_highlight) if loop_again
    end

    @platform_output += partial('partials/_caption',
                            :locals => { :value => text,
                                         :numbered => (@annotation_count > 1) })
  end

  def inner_text(node)
    node.text.strip
  end

  def parse_doc
    @skip_next = 0
    @annotation_text_count = 0
    @annotation_count = 0
    @platform_output = ''
    @document_obj.children.each_with_index do |node, index|
      unless @skip_next.zero?
        @skip_next -= 1
        next
      end

      # Process end of text mark
      break unless inner_text(node).scan(/###+/).empty?

      node = fix_links node
      # Process images
      next if process_images(node)

      # Process annotations
      next if process_annotations(node, index)

      process_highlights(node)
    end
    @platform_output
  end

  def fix_links(node)
    node_copy = node.dup
    node_copy.css('a').each do |a_tag|
      link = a_tag.attributes['href']
                  .value
                  .sub('https://www.google.com/url?q=', '')
                  .split('&')[0]
      a_tag.attributes['href'].value = link
    end
    node_copy
  end
end
