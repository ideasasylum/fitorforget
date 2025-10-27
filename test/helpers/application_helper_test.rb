require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  # Task 2.1: Tests for video_embed_html helper

  test "returns nil for blank URL" do
    assert_nil video_embed_html(nil)
    assert_nil video_embed_html("")
    assert_nil video_embed_html("   ")
  end

  test "parses YouTube watch URL and generates embed" do
    url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    result = video_embed_html(url)

    assert_not_nil result
    assert_includes result, "iframe"
    assert_includes result, "youtube-nocookie.com/embed/dQw4w9WgXcQ"
    assert_includes result, "aspect-video"
    assert_includes result, 'loading="lazy"'
  end

  test "parses YouTube short URL (youtu.be)" do
    url = "https://youtu.be/dQw4w9WgXcQ"
    result = video_embed_html(url)

    assert_not_nil result
    assert_includes result, "youtube-nocookie.com/embed/dQw4w9WgXcQ"
  end

  test "parses YouTube embed URL" do
    url = "https://www.youtube.com/embed/dQw4w9WgXcQ"
    result = video_embed_html(url)

    assert_not_nil result
    assert_includes result, "youtube-nocookie.com/embed/dQw4w9WgXcQ"
  end

  test "parses Instagram post URL and generates embed" do
    url = "https://www.instagram.com/p/ABC123xyz/"
    result = video_embed_html(url)

    assert_not_nil result
    assert_includes result, "iframe"
    assert_includes result, "instagram.com/p/ABC123xyz/embed"
    assert_includes result, "aspect-square"
    assert_includes result, 'loading="lazy"'
  end

  test "parses Instagram reel URL" do
    url = "https://www.instagram.com/reel/ABC123xyz/"
    result = video_embed_html(url)

    assert_not_nil result
    assert_includes result, "instagram.com/reel/ABC123xyz/embed"
  end

  test "returns nil for unsupported URL" do
    assert_nil video_embed_html("https://vimeo.com/123456")
    assert_nil video_embed_html("https://example.com/video.mp4")
    assert_nil video_embed_html("not-a-valid-url")
  end
end
