#include <gtest/gtest.h>

#include <sourcemeta/registry/html_escape.h>

// Basic escaping tests
TEST(HTML_escape, empty_string) {
  using namespace sourcemeta::registry::html;

  std::string text = "";
  escape(text);
  EXPECT_EQ(text, "");
}

TEST(HTML_escape, no_escape_needed_letters) {
  using namespace sourcemeta::registry::html;

  std::string text = "hello";
  escape(text);
  EXPECT_EQ(text, "hello");
}

TEST(HTML_escape, no_escape_needed_alphanumeric) {
  using namespace sourcemeta::registry::html;

  std::string text = "test123";
  escape(text);
  EXPECT_EQ(text, "test123");
}

TEST(HTML_escape, no_escape_needed_spaces_only) {
  using namespace sourcemeta::registry::html;

  std::string text = "   ";
  escape(text);
  EXPECT_EQ(text, "   ");
}

// Ampersand escaping tests
TEST(HTML_escape, ampersand_single) {
  using namespace sourcemeta::registry::html;

  std::string text = "&";
  escape(text);
  EXPECT_EQ(text, "&amp;");
}

TEST(HTML_escape, ampersand_in_text) {
  using namespace sourcemeta::registry::html;

  std::string text = "Tom & Jerry";
  escape(text);
  EXPECT_EQ(text, "Tom &amp; Jerry");
}

TEST(HTML_escape, ampersand_multiple) {
  using namespace sourcemeta::registry::html;

  std::string text = "A&B&C";
  escape(text);
  EXPECT_EQ(text, "A&amp;B&amp;C");
}

TEST(HTML_escape, ampersand_already_escaped) {
  using namespace sourcemeta::registry::html;

  std::string text = "&amp;";
  escape(text);
  EXPECT_EQ(text, "&amp;amp;");
}

TEST(HTML_escape, ampersand_business_context) {
  using namespace sourcemeta::registry::html;

  std::string text = "R&D";
  escape(text);
  EXPECT_EQ(text, "R&amp;D");
}

// Less-than escaping tests
TEST(HTML_escape, less_than_single) {
  using namespace sourcemeta::registry::html;

  std::string text = "<";
  escape(text);
  EXPECT_EQ(text, "&lt;");
}

TEST(HTML_escape, less_than_in_comparison) {
  using namespace sourcemeta::registry::html;

  std::string text = "x < y";
  escape(text);
  EXPECT_EQ(text, "x &lt; y");
}

TEST(HTML_escape, less_than_tag_like) {
  using namespace sourcemeta::registry::html;

  std::string text = "<script>";
  escape(text);
  EXPECT_EQ(text, "&lt;script&gt;");
}

TEST(HTML_escape, less_than_multiple) {
  using namespace sourcemeta::registry::html;

  std::string text = "a<b<c";
  escape(text);
  EXPECT_EQ(text, "a&lt;b&lt;c");
}

// Greater-than escaping tests
TEST(HTML_escape, greater_than_single) {
  using namespace sourcemeta::registry::html;

  std::string text = ">";
  escape(text);
  EXPECT_EQ(text, "&gt;");
}

TEST(HTML_escape, greater_than_in_comparison) {
  using namespace sourcemeta::registry::html;

  std::string text = "x > y";
  escape(text);
  EXPECT_EQ(text, "x &gt; y");
}

TEST(HTML_escape, greater_than_multiple) {
  using namespace sourcemeta::registry::html;

  std::string text = "a>b>c";
  escape(text);
  EXPECT_EQ(text, "a&gt;b&gt;c");
}

// Double quote escaping tests
TEST(HTML_escape, double_quote_single) {
  using namespace sourcemeta::registry::html;

  std::string text = "\"";
  escape(text);
  EXPECT_EQ(text, "&quot;");
}

TEST(HTML_escape, double_quote_in_sentence) {
  using namespace sourcemeta::registry::html;

  std::string text = "She said \"Hello\"";
  escape(text);
  EXPECT_EQ(text, "She said &quot;Hello&quot;");
}

TEST(HTML_escape, double_quote_consecutive) {
  using namespace sourcemeta::registry::html;

  std::string text = "\"\"";
  escape(text);
  EXPECT_EQ(text, "&quot;&quot;");
}

TEST(HTML_escape, double_quote_attribute_like) {
  using namespace sourcemeta::registry::html;

  std::string text = "value=\"test\"";
  escape(text);
  EXPECT_EQ(text, "value=&quot;test&quot;");
}

// Single quote escaping tests
TEST(HTML_escape, single_quote_single) {
  using namespace sourcemeta::registry::html;

  std::string text = "'";
  escape(text);
  EXPECT_EQ(text, "&#39;");
}

TEST(HTML_escape, single_quote_contraction) {
  using namespace sourcemeta::registry::html;

  std::string text = "It's";
  escape(text);
  EXPECT_EQ(text, "It&#39;s");
}

TEST(HTML_escape, single_quote_cant) {
  using namespace sourcemeta::registry::html;

  std::string text = "can't";
  escape(text);
  EXPECT_EQ(text, "can&#39;t");
}

TEST(HTML_escape, single_quote_consecutive) {
  using namespace sourcemeta::registry::html;

  std::string text = "''";
  escape(text);
  EXPECT_EQ(text, "&#39;&#39;");
}

// Combined entity tests
TEST(HTML_escape, all_five_entities) {
  using namespace sourcemeta::registry::html;

  std::string text = "&<>'\"";
  escape(text);
  EXPECT_EQ(text, "&amp;&lt;&gt;&#39;&quot;");
}

TEST(HTML_escape, html_tag_with_attributes) {
  using namespace sourcemeta::registry::html;

  std::string text =
      "<tag attr=\"value\" data-test='other'>content & more</tag>";
  escape(text);
  EXPECT_EQ(text,
            "&lt;tag attr=&quot;value&quot; "
            "data-test=&#39;other&#39;&gt;content &amp; more&lt;/tag&gt;");
}

TEST(HTML_escape, mixed_quotes_and_ampersand) {
  using namespace sourcemeta::registry::html;

  std::string text = "Hello & \"World\" <test>";
  escape(text);
  EXPECT_EQ(text, "Hello &amp; &quot;World&quot; &lt;test&gt;");
}

// XSS prevention tests
TEST(HTML_escape, script_tag_xss) {
  using namespace sourcemeta::registry::html;

  std::string text = "<script>alert('xss')</script>";
  escape(text);
  EXPECT_EQ(text, "&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;");
}

TEST(HTML_escape, img_onerror_xss) {
  using namespace sourcemeta::registry::html;

  std::string text = "<img src='x' onerror='alert(1)'>";
  escape(text);
  EXPECT_EQ(text, "&lt;img src=&#39;x&#39; onerror=&#39;alert(1)&#39;&gt;");
}

TEST(HTML_escape, svg_onload_xss) {
  using namespace sourcemeta::registry::html;

  std::string text = "<svg onload=alert(1)>";
  escape(text);
  EXPECT_EQ(text, "&lt;svg onload=alert(1)&gt;");
}

TEST(HTML_escape, javascript_url) {
  using namespace sourcemeta::registry::html;

  std::string text = "javascript:alert('test')";
  escape(text);
  EXPECT_EQ(text, "javascript:alert(&#39;test&#39;)");
}

// Mutation XSS prevention (2025 spec changes)
TEST(HTML_escape, mxss_img_in_attribute) {
  using namespace sourcemeta::registry::html;

  std::string text = "attr='<img src=x onerror=alert(1)>'";
  escape(text);
  EXPECT_EQ(text, "attr=&#39;&lt;img src=x onerror=alert(1)&gt;&#39;");
}

TEST(HTML_escape, mxss_svg_in_attribute) {
  using namespace sourcemeta::registry::html;

  std::string text = "data=\"<svg onload=alert('xss')>\"";
  escape(text);
  EXPECT_EQ(text, "data=&quot;&lt;svg onload=alert(&#39;xss&#39;)&gt;&quot;");
}

TEST(HTML_escape, mxss_iframe_javascript) {
  using namespace sourcemeta::registry::html;

  std::string text = "<iframe src=\"javascript:alert('xss')\">";
  escape(text);
  EXPECT_EQ(text,
            "&lt;iframe src=&quot;javascript:alert(&#39;xss&#39;)&quot;&gt;");
}

// Unicode and special characters
TEST(HTML_escape, unicode_cafe) {
  using namespace sourcemeta::registry::html;

  std::string text = "café";
  escape(text);
  EXPECT_EQ(text, "café");
}

TEST(HTML_escape, unicode_naive) {
  using namespace sourcemeta::registry::html;

  std::string text = "naïve";
  escape(text);
  EXPECT_EQ(text, "naïve");
}

TEST(HTML_escape, unicode_japanese) {
  using namespace sourcemeta::registry::html;

  std::string text = "東京";
  escape(text);
  EXPECT_EQ(text, "東京");
}

TEST(HTML_escape, unicode_emoji) {
  using namespace sourcemeta::registry::html;

  std::string text = "🚀";
  escape(text);
  EXPECT_EQ(text, "🚀");
}

TEST(HTML_escape, unicode_with_html_entities) {
  using namespace sourcemeta::registry::html;

  std::string text = "café & 東京 < 🚀";
  escape(text);
  EXPECT_EQ(text, "café &amp; 東京 &lt; 🚀");
}

// Whitespace handling
TEST(HTML_escape, newline_only) {
  using namespace sourcemeta::registry::html;

  std::string text = "\n";
  escape(text);
  EXPECT_EQ(text, "\n");
}

TEST(HTML_escape, tab_only) {
  using namespace sourcemeta::registry::html;

  std::string text = "\t";
  escape(text);
  EXPECT_EQ(text, "\t");
}

TEST(HTML_escape, carriage_return_only) {
  using namespace sourcemeta::registry::html;

  std::string text = "\r";
  escape(text);
  EXPECT_EQ(text, "\r");
}

TEST(HTML_escape, multiline_text) {
  using namespace sourcemeta::registry::html;

  std::string text = "line1\nline2";
  escape(text);
  EXPECT_EQ(text, "line1\nline2");
}

TEST(HTML_escape, whitespace_with_entities) {
  using namespace sourcemeta::registry::html;

  std::string text = "line1\n<tag> & test";
  escape(text);
  EXPECT_EQ(text, "line1\n&lt;tag&gt; &amp; test");
}

// Already escaped content
TEST(HTML_escape, numeric_entity_39) {
  using namespace sourcemeta::registry::html;

  std::string text = "&#39;";
  escape(text);
  EXPECT_EQ(text, "&amp;#39;");
}

TEST(HTML_escape, numeric_entity_34) {
  using namespace sourcemeta::registry::html;

  std::string text = "&#34;";
  escape(text);
  EXPECT_EQ(text, "&amp;#34;");
}

TEST(HTML_escape, hex_entity) {
  using namespace sourcemeta::registry::html;

  std::string text = "&#x27;";
  escape(text);
  EXPECT_EQ(text, "&amp;#x27;");
}

TEST(HTML_escape, numeric_entity_60) {
  using namespace sourcemeta::registry::html;

  std::string text = "&#60;";
  escape(text);
  EXPECT_EQ(text, "&amp;#60;");
}

// HTML structures
TEST(HTML_escape, div_with_class) {
  using namespace sourcemeta::registry::html;

  std::string text = "<div class=\"container\">";
  escape(text);
  EXPECT_EQ(text, "&lt;div class=&quot;container&quot;&gt;");
}

TEST(HTML_escape, input_with_mixed_quotes) {
  using namespace sourcemeta::registry::html;

  std::string text = "<input type='text' value=\"test\">";
  escape(text);
  EXPECT_EQ(text, "&lt;input type=&#39;text&#39; value=&quot;test&quot;&gt;");
}

TEST(HTML_escape, html_document_end) {
  using namespace sourcemeta::registry::html;

  std::string text = "</body></html>";
  escape(text);
  EXPECT_EQ(text, "&lt;/body&gt;&lt;/html&gt;");
}

TEST(HTML_escape, meta_charset) {
  using namespace sourcemeta::registry::html;

  std::string text = "<meta charset=\"utf-8\">";
  escape(text);
  EXPECT_EQ(text, "&lt;meta charset=&quot;utf-8&quot;&gt;");
}

// HTML comments
TEST(HTML_escape, basic_html_comment) {
  using namespace sourcemeta::registry::html;

  std::string text = "<!-- comment -->";
  escape(text);
  EXPECT_EQ(text, "&lt;!-- comment --&gt;");
}

TEST(HTML_escape, comment_with_entities) {
  using namespace sourcemeta::registry::html;

  std::string text = "<!-- <script> & 'test' -->";
  escape(text);
  EXPECT_EQ(text, "&lt;!-- &lt;script&gt; &amp; &#39;test&#39; --&gt;");
}

// CSS and JavaScript content
TEST(HTML_escape, css_with_quotes) {
  using namespace sourcemeta::registry::html;

  std::string text = "body { color: 'red'; }";
  escape(text);
  EXPECT_EQ(text, "body { color: &#39;red&#39;; }");
}

TEST(HTML_escape, css_selector) {
  using namespace sourcemeta::registry::html;

  std::string text = "div > p";
  escape(text);
  EXPECT_EQ(text, "div &gt; p");
}

TEST(HTML_escape, javascript_condition) {
  using namespace sourcemeta::registry::html;

  std::string text = "if (x < y && z > 'test') { alert(\"hello\"); }";
  escape(text);
  EXPECT_EQ(text, "if (x &lt; y &amp;&amp; z &gt; &#39;test&#39;) { "
                  "alert(&quot;hello&quot;); }");
}

// CDATA sections
TEST(HTML_escape, cdata_basic) {
  using namespace sourcemeta::registry::html;

  std::string text = "<![CDATA[content]]>";
  escape(text);
  EXPECT_EQ(text, "&lt;![CDATA[content]]&gt;");
}

TEST(HTML_escape, cdata_with_entities) {
  using namespace sourcemeta::registry::html;

  std::string text = "<![CDATA[<tag> & 'test']]>";
  escape(text);
  EXPECT_EQ(text, "&lt;![CDATA[&lt;tag&gt; &amp; &#39;test&#39;]]&gt;");
}

// URL scenarios
TEST(HTML_escape, url_with_query_params) {
  using namespace sourcemeta::registry::html;

  std::string text = "http://example.com?param='value'&other=\"test\"";
  escape(text);
  EXPECT_EQ(
      text,
      "http://example.com?param=&#39;value&#39;&amp;other=&quot;test&quot;");
}

TEST(HTML_escape, search_url_with_script) {
  using namespace sourcemeta::registry::html;

  std::string text = "search?q=<script>&format='json'";
  escape(text);
  EXPECT_EQ(text, "search?q=&lt;script&gt;&amp;format=&#39;json&#39;");
}

// Performance edge cases
TEST(HTML_escape, long_string_no_escaping) {
  using namespace sourcemeta::registry::html;

  std::string text = "abcdefghijklmnopqrstuvwxyz0123456789";
  std::string expected = text;
  escape(text);
  EXPECT_EQ(text, expected);
}

TEST(HTML_escape, consecutive_ampersands) {
  using namespace sourcemeta::registry::html;

  std::string text = "&&&";
  escape(text);
  EXPECT_EQ(text, "&amp;&amp;&amp;");
}

TEST(HTML_escape, consecutive_less_than) {
  using namespace sourcemeta::registry::html;

  std::string text = "<<<";
  escape(text);
  EXPECT_EQ(text, "&lt;&lt;&lt;");
}

TEST(HTML_escape, consecutive_greater_than) {
  using namespace sourcemeta::registry::html;

  std::string text = ">>>";
  escape(text);
  EXPECT_EQ(text, "&gt;&gt;&gt;");
}

TEST(HTML_escape, consecutive_double_quotes) {
  using namespace sourcemeta::registry::html;

  std::string text = "\"\"\"";
  escape(text);
  EXPECT_EQ(text, "&quot;&quot;&quot;");
}

TEST(HTML_escape, consecutive_single_quotes) {
  using namespace sourcemeta::registry::html;

  std::string text = "'''";
  escape(text);
  EXPECT_EQ(text, "&#39;&#39;&#39;");
}

// Complex mixed scenarios
TEST(HTML_escape, complex_mixed_content) {
  using namespace sourcemeta::registry::html;

  std::string text = "This is a test & it contains < and > symbols, "
                     "\"quotes\", 'apostrophes', and <tags>";
  escape(text);
  EXPECT_EQ(text,
            "This is a test &amp; it contains &lt; and &gt; symbols, "
            "&quot;quotes&quot;, &#39;apostrophes&#39;, and &lt;tags&gt;");
}

TEST(HTML_escape, possessive_with_quotes_and_entities) {
  using namespace sourcemeta::registry::html;

  std::string text = "Tom's \"Café\" & Jerry's <adventures>";
  escape(text);
  EXPECT_EQ(text,
            "Tom&#39;s &quot;Café&quot; &amp; Jerry&#39;s &lt;adventures&gt;");
}
