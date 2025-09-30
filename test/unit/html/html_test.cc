#include <gtest/gtest.h>

#include <sourcemeta/registry/html.h>

TEST(HTML, example_1) {
  using namespace sourcemeta::registry::html;

  std::vector<HTML> items;
  for (const auto &item : {"foo", "bar", "baz"}) {
    items.push_back(li(item));
  }

  std::ostringstream result;
  result << div(h1("Title"), ul({{"class", "my-list"}}, items), p("Footer"));

  EXPECT_EQ(result.str(), "<div><h1>Title</h1><ul "
                          "class=\"my-list\"><li>foo</li><li>bar</li><li>baz</"
                          "li></ul><p>Footer</p></div>");
}

TEST(HTML, escaped_text_content) {
  using namespace sourcemeta::registry::html;

  std::ostringstream result;
  result << p(
      "This contains <dangerous> & \"potentially\" 'harmful' characters");

  EXPECT_EQ(result.str(),
            "<p>This contains &lt;dangerous&gt; &amp; &quot;potentially&quot; "
            "&#39;harmful&#39; characters</p>");
}

TEST(HTML, raw_html_basic) {
  using namespace sourcemeta::registry::html;

  std::ostringstream result;
  result << div(raw("<strong>Bold text</strong>"));

  EXPECT_EQ(result.str(), "<div><strong>Bold text</strong></div>");
}

TEST(HTML, raw_html_with_dangerous_content) {
  using namespace sourcemeta::registry::html;

  std::ostringstream result;
  result << div(raw("<script>alert('xss')</script>"));

  EXPECT_EQ(result.str(), "<div><script>alert('xss')</script></div>");
}

TEST(HTML, raw_html_mixed_with_escaped) {
  using namespace sourcemeta::registry::html;

  std::ostringstream result;
  result << div("Safe text: <script>", raw("<em>raw italic</em>"),
                " & more safe text");

  EXPECT_EQ(result.str(), "<div>Safe text: &lt;script&gt;<em>raw italic</em> "
                          "&amp; more safe text</div>");
}

TEST(HTML, raw_html_in_list) {
  using namespace sourcemeta::registry::html;

  std::ostringstream result;
  result << ul(li("Regular item"), li(raw("<strong>Bold</strong> item")),
               li("Another & escaped item"));

  EXPECT_EQ(result.str(), "<ul><li>Regular item</li><li><strong>Bold</strong> "
                          "item</li><li>Another &amp; escaped item</li></ul>");
}

TEST(HTML, raw_html_empty_content) {
  using namespace sourcemeta::registry::html;

  std::ostringstream result;
  result << div(raw(""));

  EXPECT_EQ(result.str(), "<div></div>");
}

TEST(HTML, raw_html_with_entities) {
  using namespace sourcemeta::registry::html;

  std::ostringstream result;
  result << div(raw("&lt;already&gt; &amp; &quot;escaped&quot;"));

  EXPECT_EQ(result.str(),
            "<div>&lt;already&gt; &amp; &quot;escaped&quot;</div>");
}

TEST(HTML, empty_elements) {
  using namespace sourcemeta::registry::html;

  EXPECT_EQ(div().render(), "<div></div>");
  EXPECT_EQ(p({}).render(), "<p></p>");
  EXPECT_EQ(span({{"class", "empty"}}).render(),
            "<span class=\"empty\"></span>");
}

TEST(HTML, void_elements_self_closing) {
  using namespace sourcemeta::registry::html;

  EXPECT_EQ(br().render(), "<br />");
  EXPECT_EQ(hr().render(), "<hr />");
  EXPECT_EQ(img({{"src", "test.png"}, {"alt", "Test"}}).render(),
            "<img alt=\"Test\" src=\"test.png\" />");
  EXPECT_EQ(input({{"type", "text"}, {"name", "test"}}).render(),
            "<input name=\"test\" type=\"text\" />");
  EXPECT_EQ(meta({{"charset", "utf-8"}}).render(),
            "<meta charset=\"utf-8\" />");
}

TEST(HTML, single_text_node_inline_rendering) {
  using namespace sourcemeta::registry::html;

  // Single text node should be rendered inline
  EXPECT_EQ(p("Hello").render(), "<p>Hello</p>");
  EXPECT_EQ(h1("Title").render(), "<h1>Title</h1>");
  EXPECT_EQ(span("Text").render(), "<span>Text</span>");
}

TEST(HTML, multiple_children_block_rendering) {
  using namespace sourcemeta::registry::html;

  // Multiple children should not be inline
  std::ostringstream result;
  result << div("Text 1", span("Text 2"));

  EXPECT_EQ(result.str(), "<div>Text 1<span>Text 2</span></div>");
}

TEST(HTML, attribute_value_escaping) {
  using namespace sourcemeta::registry::html;

  std::ostringstream result;
  result << div({{"title", "Alert: \"Click here\" & 'submit'"},
                 {"data-value", "<script>alert('xss')</script>"}},
                "Content");

  EXPECT_EQ(
      result.str(),
      "<div data-value=\"&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;\" "
      "title=\"Alert: &quot;Click here&quot; &amp; "
      "&#39;submit&#39;\">Content</div>");
}

TEST(HTML, empty_attribute_values) {
  using namespace sourcemeta::registry::html;

  std::ostringstream result;
  result << input(
      {{"type", "text"}, {"value", ""}, {"placeholder", "Enter text"}});

  EXPECT_EQ(result.str(),
            "<input placeholder=\"Enter text\" type=\"text\" value=\"\" />");
}

TEST(HTML, nested_html_elements) {
  using namespace sourcemeta::registry::html;

  std::ostringstream result;
  result << div(
      p("First paragraph"),
      div({{"class", "nested"}}, span("Nested content"), strong("Important")),
      p("Last paragraph"));

  EXPECT_EQ(result.str(),
            "<div><p>First paragraph</p><div class=\"nested\">"
            "<span>Nested content</span><strong>Important</strong></div>"
            "<p>Last paragraph</p></div>");
}

TEST(HTML, complex_table_structure) {
  using namespace sourcemeta::registry::html;

  std::ostringstream result;
  result << table(thead(tr(th("Name"), th("Age"), th("City"))),
                  tbody(tr(td("John"), td("25"), td("NYC")),
                        tr(td("Jane"), td("30"), td("LA"))),
                  tfoot(tr(td({{"colspan", "3"}}, "2 rows total"))));

  std::string expected =
      "<table><thead><tr><th>Name</th><th>Age</th><th>City</th></tr></thead>"
      "<tbody><tr><td>John</td><td>25</td><td>NYC</td></tr>"
      "<tr><td>Jane</td><td>30</td><td>LA</td></tr></tbody>"
      "<tfoot><tr><td colspan=\"3\">2 rows "
      "total</td></tr></tfoot></table>";

  EXPECT_EQ(result.str(), expected);
}

TEST(HTML, form_elements_combination) {
  using namespace sourcemeta::registry::html;

  std::ostringstream result;
  result << form(
      {{"action", "/submit"}, {"method", "post"}},
      fieldset(legend("Personal Info"), label({{"for", "name"}}, "Name:"),
               input({{"type", "text"}, {"id", "name"}, {"name", "name"}}),
               label({{"for", "age"}}, "Age:"),
               select({{"id", "age"}, {"name", "age"}},
                      option({{"value", ""}}, "Select age"),
                      option({{"value", "18-25"}}, "18-25"),
                      option({{"value", "26-35"}}, "26-35"))),
      button({{"type", "submit"}}, "Submit"));

  std::string expected = "<form action=\"/submit\" method=\"post\">"
                         "<fieldset><legend>Personal Info</legend>"
                         "<label for=\"name\">Name:</label>"
                         "<input id=\"name\" name=\"name\" type=\"text\" />"
                         "<label for=\"age\">Age:</label>"
                         "<select id=\"age\" name=\"age\">"
                         "<option value=\"\">Select age</option>"
                         "<option value=\"18-25\">18-25</option>"
                         "<option value=\"26-35\">26-35</option>"
                         "</select></fieldset>"
                         "<button type=\"submit\">Submit</button></form>";

  EXPECT_EQ(result.str(), expected);
}

TEST(HTML, unicode_and_special_characters) {
  using namespace sourcemeta::registry::html;

  std::ostringstream result;
  result << p("Unicode: 你好世界 🌍 ñáéíóú");

  EXPECT_EQ(result.str(), "<p>Unicode: 你好世界 🌍 ñáéíóú</p>");
}

TEST(HTML, whitespace_handling) {
  using namespace sourcemeta::registry::html;

  std::ostringstream result;
  result << pre("  Whitespace\n  should be\n    preserved  ");

  EXPECT_EQ(result.str(),
            "<pre>  Whitespace\n  should be\n    preserved  </pre>");
}

TEST(HTML, mixed_raw_and_escaped_complex) {
  using namespace sourcemeta::registry::html;

  std::ostringstream result;
  result << article(h2("Article Title & <subtitle>"),
                    p("Normal text with ", em("emphasis"), " and ",
                      raw("<mark>highlighted</mark>"), " parts."),
                    raw("<!-- Raw HTML comment -->"),
                    p("More content & special chars"));

  std::string expected = "<article>"
                         "<h2>Article Title &amp; &lt;subtitle&gt;</h2>"
                         "<p>Normal text with <em>emphasis</em> and "
                         "<mark>highlighted</mark> parts.</p>"
                         "<!-- Raw HTML comment -->"
                         "<p>More content &amp; special chars</p>"
                         "</article>";

  EXPECT_EQ(result.str(), expected);
}

TEST(HTML, semantic_html5_elements) {
  using namespace sourcemeta::registry::html;

  std::ostringstream result;
  result << main({{"role", "main"}},
                 header(nav(ul(li(a({{"href", "/"}}, "Home")),
                               li(a({{"href", "/about"}}, "About"))))),
                 section(article(h1("Article Title"), p("Article content")),
                         aside("Sidebar content")),
                 footer("Copyright 2024"));

  std::string expected = "<main role=\"main\">"
                         "<header><nav><ul>"
                         "<li><a href=\"/\">Home</a></li>"
                         "<li><a href=\"/about\">About</a></li>"
                         "</ul></nav></header>"
                         "<section><article>"
                         "<h1>Article Title</h1>"
                         "<p>Article content</p>"
                         "</article>"
                         "<aside>Sidebar content</aside></section>"
                         "<footer>Copyright 2024</footer>"
                         "</main>";

  EXPECT_EQ(result.str(), expected);
}

TEST(HTML, attribute_order_consistency) {
  using namespace sourcemeta::registry::html;

  // Since std::map orders keys lexicographically, attributes should be
  // consistent
  std::ostringstream result;
  result << div({{"z-index", "1"}, {"class", "test"}, {"id", "main"}},
                "Content");

  EXPECT_EQ(result.str(),
            "<div class=\"test\" id=\"main\" z-index=\"1\">Content</div>");
}

TEST(HTML, zero_length_strings) {
  using namespace sourcemeta::registry::html;

  EXPECT_EQ(p("").render(), "<p></p>");
  EXPECT_EQ(span({{"class", ""}}, "").render(), "<span class=\"\"></span>");
}

TEST(HTML, push_back_string) {
  using namespace sourcemeta::registry::html;

  auto element = div();
  element.push_back(std::string("Hello World"));

  EXPECT_EQ(element.render(), "<div>Hello World</div>");
}

TEST(HTML, push_back_string_chaining) {
  using namespace sourcemeta::registry::html;

  auto element = div()
                     .push_back(std::string("First"))
                     .push_back(std::string(" "))
                     .push_back(std::string("Second"));

  EXPECT_EQ(element.render(), "<div>First Second</div>");
}

TEST(HTML, push_back_html_element) {
  using namespace sourcemeta::registry::html;

  auto element = div();
  element.push_back(span("Nested span"));

  EXPECT_EQ(element.render(), "<div><span>Nested span</span></div>");
}

TEST(HTML, push_back_html_element_chaining) {
  using namespace sourcemeta::registry::html;

  auto element = div()
                     .push_back(h1("Title"))
                     .push_back(p("Paragraph"))
                     .push_back(span("Footer"));

  EXPECT_EQ(element.render(),
            "<div><h1>Title</h1><p>Paragraph</p><span>Footer</span></div>");
}

TEST(HTML, push_back_raw_html) {
  using namespace sourcemeta::registry::html;

  auto element = div();
  element.push_back(raw("<strong>Bold text</strong>"));

  EXPECT_EQ(element.render(), "<div><strong>Bold text</strong></div>");
}

TEST(HTML, push_back_raw_html_chaining) {
  using namespace sourcemeta::registry::html;

  auto element = div()
                     .push_back(raw("<em>Italic</em>"))
                     .push_back(std::string(" and "))
                     .push_back(raw("<strong>Bold</strong>"));

  EXPECT_EQ(element.render(),
            "<div><em>Italic</em> and <strong>Bold</strong></div>");
}

TEST(HTML, push_back_mixed_content) {
  using namespace sourcemeta::registry::html;

  auto element = div();
  element.push_back(std::string("Text: "))
      .push_back(span("Nested"))
      .push_back(std::string(" & "))
      .push_back(raw("<em>Raw HTML</em>"));

  EXPECT_EQ(element.render(),
            "<div>Text: <span>Nested</span> &amp; <em>Raw HTML</em></div>");
}

TEST(HTML, push_back_with_attributes) {
  using namespace sourcemeta::registry::html;

  auto element = div({{"class", "container"}, {"id", "main"}});
  element.push_back(std::string("Content")).push_back(p("Paragraph"));

  EXPECT_EQ(
      element.render(),
      "<div class=\"container\" id=\"main\">Content<p>Paragraph</p></div>");
}

TEST(HTML, push_back_to_existing_children) {
  using namespace sourcemeta::registry::html;

  auto element = div("Initial content");
  element.push_back(std::string(" ")).push_back(span("Added span"));

  EXPECT_EQ(element.render(),
            "<div>Initial content <span>Added span</span></div>");
}

TEST(HTML, push_back_complex_nesting) {
  using namespace sourcemeta::registry::html;

  auto list = ul();
  list.push_back(li("Item 1"))
      .push_back(li().push_back(std::string("Item 2 with "))
                     .push_back(strong("emphasis")))
      .push_back(li().push_back(raw("<em>Item 3</em>")));

  EXPECT_EQ(list.render(),
            "<ul><li>Item 1</li><li>Item 2 with <strong>emphasis</strong></li>"
            "<li><em>Item 3</em></li></ul>");
}

TEST(HTML, push_back_escaped_content) {
  using namespace sourcemeta::registry::html;

  auto element = div();
  element.push_back(std::string("Safe: <script>alert('xss')</script>"));

  EXPECT_EQ(
      element.render(),
      "<div>Safe: &lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;</div>");
}

TEST(HTML, push_back_return_reference) {
  using namespace sourcemeta::registry::html;

  auto element = div();
  auto &ref = element.push_back(std::string("test"));

  // Verify that push_back returns a reference to the same object
  EXPECT_EQ(&ref, &element);
}
