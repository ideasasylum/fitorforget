module ApplicationHelper
  def markdown(text)
    return "" if text.blank?

    renderer = Redcarpet::Render::HTML.new(hard_wrap: true, filter_html: false)
    markdown = Redcarpet::Markdown.new(renderer, autolink: true, tables: true, fenced_code_blocks: true, strikethrough: true)
    markdown.render(text).html_safe
  end

  # Task 2.2-2.7: Video embedding helper
  def video_embed_html(url)
    # Task 2.2: Return nil if url is blank
    return nil if url.blank?

    # Task 2.3-2.4: YouTube URL detection and embed generation
    if (video_id = extract_youtube_id(url))
      return youtube_embed_html(video_id)
    end

    # Task 2.5-2.6: Instagram URL detection and embed generation
    if (post_id = extract_instagram_id(url))
      return instagram_embed_html(post_id)
    end

    # Task 2.7: Return nil for unsupported URLs
    nil
  end

  private

  def extract_youtube_id(url)
    # Match youtube.com/watch?v=VIDEO_ID
    if url.match(%r{youtube\.com/watch\?v=([^&]+)})
      return $1
    end

    # Match youtu.be/VIDEO_ID
    if url.match(%r{youtu\.be/([^?]+)})
      return $1
    end

    # Match youtube.com/embed/VIDEO_ID
    if url.match(%r{youtube\.com/embed/([^?]+)})
      return $1
    end

    nil
  end

  def extract_instagram_id(url)
    # Match instagram.com/p/POST_ID or instagram.com/reel/REEL_ID
    if url.match(%r{instagram\.com/(p|reel)/([^/?]+)})
      return { type: $1, id: $2 }
    end

    nil
  end

  def youtube_embed_html(video_id)
    <<~HTML.html_safe
      <div class="aspect-video">
        <iframe src="https://www.youtube-nocookie.com/embed/#{video_id}"
                class="w-full h-full rounded-lg"
                frameborder="0"
                loading="lazy"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowfullscreen>
        </iframe>
      </div>
    HTML
  end

  def instagram_embed_html(post_data)
    type = post_data[:type]
    id = post_data[:id]

    <<~HTML.html_safe
      <div class="aspect-square max-w-md mx-auto">
        <iframe src="https://www.instagram.com/#{type}/#{id}/embed"
                class="w-full h-full rounded-lg"
                frameborder="0"
                loading="lazy"
                scrolling="no">
        </iframe>
      </div>
    HTML
  end
end
