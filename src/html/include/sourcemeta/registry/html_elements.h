#ifndef SOURCEMETA_REGISTRY_HTML_ELEMENTS_H_
#define SOURCEMETA_REGISTRY_HTML_ELEMENTS_H_

#include <sourcemeta/registry/html_encoder.h>

namespace sourcemeta::registry::html {

#define HTML_VOID_ELEMENT(name)                                                \
  inline auto name() -> HTML { return HTML(#name, true); }                     \
  inline auto name(Attributes attributes) -> HTML {                            \
    return HTML(#name, std::move(attributes), true);                           \
  }

#define HTML_CONTAINER_ELEMENT(name)                                           \
  inline auto name(Attributes attributes) -> HTML {                            \
    return HTML(#name, std::move(attributes));                                 \
  }                                                                            \
  template <typename... Children>                                              \
  inline auto name(Attributes attributes, Children &&...children) -> HTML {    \
    return HTML(#name, std::move(attributes),                                  \
                std::forward<Children>(children)...);                          \
  }                                                                            \
  template <typename... Children>                                              \
  inline auto name(Children &&...children) -> HTML {                           \
    return HTML(#name, std::forward<Children>(children)...);                   \
  }

#define HTML_COMPACT_ELEMENT(name)                                             \
  inline auto name(Attributes attributes) -> HTML {                            \
    return HTML(#name, std::move(attributes));                                 \
  }                                                                            \
  template <typename... Children>                                              \
  inline auto name(Attributes attributes, Children &&...children) -> HTML {    \
    return HTML(#name, std::move(attributes),                                  \
                std::forward<Children>(children)...);                          \
  }                                                                            \
  template <typename... Children>                                              \
  inline auto name(Children &&...children) -> HTML {                           \
    return HTML(#name, std::forward<Children>(children)...);                   \
  }

#define HTML_VOID_ATTR_ELEMENT(name)                                           \
  inline auto name(Attributes attributes) -> HTML {                            \
    return HTML(#name, std::move(attributes), true);                           \
  }

// =============================================================================
// Document Structure Elements
// =============================================================================

// The Root Element
// https://html.spec.whatwg.org/multipage/semantics.html#the-html-element
HTML_CONTAINER_ELEMENT(html)

// Document Metadata
// https://html.spec.whatwg.org/multipage/semantics.html#the-base-element
HTML_VOID_ATTR_ELEMENT(base)

// https://html.spec.whatwg.org/multipage/semantics.html#the-head-element
HTML_CONTAINER_ELEMENT(head)

// https://html.spec.whatwg.org/multipage/semantics.html#the-link-element
HTML_VOID_ATTR_ELEMENT(link)

// https://html.spec.whatwg.org/multipage/semantics.html#the-meta-element
HTML_VOID_ATTR_ELEMENT(meta)

// https://html.spec.whatwg.org/multipage/semantics.html#the-style-element
HTML_CONTAINER_ELEMENT(style)

// https://html.spec.whatwg.org/multipage/semantics.html#the-title-element
HTML_CONTAINER_ELEMENT(title)

// Sectioning Root
// https://html.spec.whatwg.org/multipage/sections.html#the-body-element
HTML_CONTAINER_ELEMENT(body)

// =============================================================================
// Content Sectioning Elements
// =============================================================================

// https://html.spec.whatwg.org/multipage/sections.html#the-address-element
HTML_CONTAINER_ELEMENT(address)

// https://html.spec.whatwg.org/multipage/sections.html#the-article-element
HTML_CONTAINER_ELEMENT(article)

// https://html.spec.whatwg.org/multipage/sections.html#the-aside-element
HTML_CONTAINER_ELEMENT(aside)

// https://html.spec.whatwg.org/multipage/sections.html#the-footer-element
HTML_CONTAINER_ELEMENT(footer)

// https://html.spec.whatwg.org/multipage/sections.html#the-header-element
HTML_CONTAINER_ELEMENT(header)

// https://html.spec.whatwg.org/multipage/sections.html#the-h1-h2-h3-h4-h5-and-h6-elements
HTML_COMPACT_ELEMENT(h1)
HTML_COMPACT_ELEMENT(h2)
HTML_COMPACT_ELEMENT(h3)
HTML_COMPACT_ELEMENT(h4)
HTML_COMPACT_ELEMENT(h5)
HTML_COMPACT_ELEMENT(h6)

// https://html.spec.whatwg.org/multipage/sections.html#the-hgroup-element
HTML_CONTAINER_ELEMENT(hgroup)

// https://html.spec.whatwg.org/multipage/grouping-content.html#the-main-element
HTML_CONTAINER_ELEMENT(main)

// https://html.spec.whatwg.org/multipage/sections.html#the-nav-element
HTML_CONTAINER_ELEMENT(nav)

// https://html.spec.whatwg.org/multipage/sections.html#the-section-element
HTML_CONTAINER_ELEMENT(section)

// https://html.spec.whatwg.org/multipage/sections.html#the-search-element
HTML_CONTAINER_ELEMENT(search)

// =============================================================================
// Text Content Elements
// =============================================================================

// https://html.spec.whatwg.org/multipage/grouping-content.html#the-blockquote-element
HTML_CONTAINER_ELEMENT(blockquote)

// https://html.spec.whatwg.org/multipage/grouping-content.html#the-dd-element
HTML_COMPACT_ELEMENT(dd)

// https://html.spec.whatwg.org/multipage/grouping-content.html#the-div-element
HTML_CONTAINER_ELEMENT(div)

// https://html.spec.whatwg.org/multipage/grouping-content.html#the-dl-element
HTML_COMPACT_ELEMENT(dl)

// https://html.spec.whatwg.org/multipage/grouping-content.html#the-dt-element
HTML_COMPACT_ELEMENT(dt)

// https://html.spec.whatwg.org/multipage/grouping-content.html#the-figcaption-element
HTML_CONTAINER_ELEMENT(figcaption)

// https://html.spec.whatwg.org/multipage/grouping-content.html#the-figure-element
HTML_CONTAINER_ELEMENT(figure)

// https://html.spec.whatwg.org/multipage/grouping-content.html#the-hr-element
HTML_VOID_ELEMENT(hr)

// https://html.spec.whatwg.org/multipage/grouping-content.html#the-li-element
HTML_COMPACT_ELEMENT(li)

// https://html.spec.whatwg.org/multipage/grouping-content.html#the-menu-element
HTML_CONTAINER_ELEMENT(menu)

// https://html.spec.whatwg.org/multipage/grouping-content.html#the-ol-element
HTML_COMPACT_ELEMENT(ol)

// https://html.spec.whatwg.org/multipage/grouping-content.html#the-p-element
HTML_COMPACT_ELEMENT(p)

// https://html.spec.whatwg.org/multipage/grouping-content.html#the-pre-element
HTML_CONTAINER_ELEMENT(pre)

// https://html.spec.whatwg.org/multipage/grouping-content.html#the-ul-element
HTML_CONTAINER_ELEMENT(ul)

// =============================================================================
// Inline Text Semantics Elements
// =============================================================================

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-a-element
HTML_COMPACT_ELEMENT(a)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-abbr-element
HTML_CONTAINER_ELEMENT(abbr)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-b-element
HTML_COMPACT_ELEMENT(b)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-bdi-element
HTML_CONTAINER_ELEMENT(bdi)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-bdo-element
HTML_CONTAINER_ELEMENT(bdo)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-br-element
HTML_VOID_ELEMENT(br)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-cite-element
HTML_CONTAINER_ELEMENT(cite)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-code-element
HTML_CONTAINER_ELEMENT(code)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-data-element
HTML_CONTAINER_ELEMENT(data)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-dfn-element
HTML_CONTAINER_ELEMENT(dfn)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-em-element
HTML_COMPACT_ELEMENT(em)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-i-element
HTML_COMPACT_ELEMENT(i)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-kbd-element
HTML_CONTAINER_ELEMENT(kbd)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-mark-element
HTML_CONTAINER_ELEMENT(mark)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-q-element
HTML_COMPACT_ELEMENT(q)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-rp-element
HTML_COMPACT_ELEMENT(rp)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-rt-element
HTML_COMPACT_ELEMENT(rt)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-ruby-element
HTML_CONTAINER_ELEMENT(ruby)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-s-element
HTML_COMPACT_ELEMENT(s)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-samp-element
HTML_CONTAINER_ELEMENT(samp)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-small-element
HTML_CONTAINER_ELEMENT(small)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-span-element
HTML_CONTAINER_ELEMENT(span)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-strong-element
HTML_CONTAINER_ELEMENT(strong)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-sub-and-sup-elements
HTML_CONTAINER_ELEMENT(sub)

HTML_CONTAINER_ELEMENT(sup)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-time-element
HTML_CONTAINER_ELEMENT(time)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-u-element
HTML_COMPACT_ELEMENT(u)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-var-element
HTML_CONTAINER_ELEMENT(var)

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-wbr-element
HTML_VOID_ELEMENT(wbr)

// =============================================================================
// Image and Multimedia Elements
// =============================================================================

// https://html.spec.whatwg.org/multipage/image-maps.html#the-area-element
HTML_VOID_ATTR_ELEMENT(area)

// https://html.spec.whatwg.org/multipage/media.html#the-audio-element
HTML_CONTAINER_ELEMENT(audio)

// https://html.spec.whatwg.org/multipage/embedded-content.html#the-img-element
HTML_VOID_ATTR_ELEMENT(img)

// https://html.spec.whatwg.org/multipage/image-maps.html#the-map-element
HTML_CONTAINER_ELEMENT(map)

// https://html.spec.whatwg.org/multipage/media.html#the-track-element
HTML_VOID_ATTR_ELEMENT(track)

// https://html.spec.whatwg.org/multipage/media.html#the-video-element
HTML_CONTAINER_ELEMENT(video)

// =============================================================================
// Embedded Content Elements
// =============================================================================

// https://html.spec.whatwg.org/multipage/iframe-embed-object.html#the-embed-element
HTML_VOID_ATTR_ELEMENT(embed)

// https://html.spec.whatwg.org/multipage/iframe-embed-object.html#the-iframe-element
HTML_CONTAINER_ELEMENT(iframe)

// https://html.spec.whatwg.org/multipage/iframe-embed-object.html#the-object-element
HTML_CONTAINER_ELEMENT(object)

// https://html.spec.whatwg.org/multipage/embedded-content.html#the-picture-element
HTML_CONTAINER_ELEMENT(picture)

// https://html.spec.whatwg.org/multipage/iframe-embed-object.html#the-portal-element
HTML_CONTAINER_ELEMENT(portal)

// https://html.spec.whatwg.org/multipage/embedded-content.html#the-source-element
HTML_VOID_ATTR_ELEMENT(source)

// =============================================================================
// Scripting Elements
// =============================================================================

// https://html.spec.whatwg.org/multipage/canvas.html#the-canvas-element
HTML_CONTAINER_ELEMENT(canvas)

// https://html.spec.whatwg.org/multipage/scripting.html#the-noscript-element
HTML_CONTAINER_ELEMENT(noscript)

// https://html.spec.whatwg.org/multipage/scripting.html#the-script-element
HTML_CONTAINER_ELEMENT(script)

// =============================================================================
// Demarcating Edits Elements
// =============================================================================

// https://html.spec.whatwg.org/multipage/edits.html#the-del-element
HTML_CONTAINER_ELEMENT(del)

// https://html.spec.whatwg.org/multipage/edits.html#the-ins-element
HTML_CONTAINER_ELEMENT(ins)

// =============================================================================
// Table Content Elements
// =============================================================================

// https://html.spec.whatwg.org/multipage/tables.html#the-caption-element
HTML_CONTAINER_ELEMENT(caption)

// https://html.spec.whatwg.org/multipage/tables.html#the-col-element
HTML_VOID_ATTR_ELEMENT(col)

// https://html.spec.whatwg.org/multipage/tables.html#the-colgroup-element
HTML_CONTAINER_ELEMENT(colgroup)

// https://html.spec.whatwg.org/multipage/tables.html#the-table-element
HTML_CONTAINER_ELEMENT(table)

// https://html.spec.whatwg.org/multipage/tables.html#the-tbody-element
HTML_CONTAINER_ELEMENT(tbody)

// https://html.spec.whatwg.org/multipage/tables.html#the-td-element
HTML_COMPACT_ELEMENT(td)

// https://html.spec.whatwg.org/multipage/tables.html#the-tfoot-element
HTML_CONTAINER_ELEMENT(tfoot)

// https://html.spec.whatwg.org/multipage/tables.html#the-th-element
HTML_COMPACT_ELEMENT(th)

// https://html.spec.whatwg.org/multipage/tables.html#the-thead-element
HTML_CONTAINER_ELEMENT(thead)

// https://html.spec.whatwg.org/multipage/tables.html#the-tr-element
HTML_CONTAINER_ELEMENT(tr)

// =============================================================================
// Forms Elements
// =============================================================================

// https://html.spec.whatwg.org/multipage/form-elements.html#the-button-element
HTML_CONTAINER_ELEMENT(button)

// https://html.spec.whatwg.org/multipage/form-elements.html#the-datalist-element
HTML_CONTAINER_ELEMENT(datalist)

// https://html.spec.whatwg.org/multipage/form-elements.html#the-fieldset-element
HTML_CONTAINER_ELEMENT(fieldset)

// https://html.spec.whatwg.org/multipage/forms.html#the-form-element
HTML_CONTAINER_ELEMENT(form)

// https://html.spec.whatwg.org/multipage/input.html#the-input-element
HTML_VOID_ATTR_ELEMENT(input)

// https://html.spec.whatwg.org/multipage/forms.html#the-label-element
HTML_CONTAINER_ELEMENT(label)

// https://html.spec.whatwg.org/multipage/form-elements.html#the-legend-element
HTML_CONTAINER_ELEMENT(legend)

// https://html.spec.whatwg.org/multipage/form-elements.html#the-meter-element
HTML_CONTAINER_ELEMENT(meter)

// https://html.spec.whatwg.org/multipage/form-elements.html#the-optgroup-element
HTML_CONTAINER_ELEMENT(optgroup)

// https://html.spec.whatwg.org/multipage/form-elements.html#the-option-element
HTML_CONTAINER_ELEMENT(option)

// https://html.spec.whatwg.org/multipage/form-elements.html#the-output-element
HTML_CONTAINER_ELEMENT(output)

// https://html.spec.whatwg.org/multipage/form-elements.html#the-progress-element
HTML_CONTAINER_ELEMENT(progress)

// https://html.spec.whatwg.org/multipage/form-elements.html#the-select-element
HTML_CONTAINER_ELEMENT(select)

// https://html.spec.whatwg.org/multipage/form-elements.html#the-textarea-element
HTML_CONTAINER_ELEMENT(textarea)

// =============================================================================
// Interactive Elements
// =============================================================================

// https://html.spec.whatwg.org/multipage/interactive-elements.html#the-details-element
HTML_CONTAINER_ELEMENT(details)

// https://html.spec.whatwg.org/multipage/interactive-elements.html#the-dialog-element
HTML_CONTAINER_ELEMENT(dialog)

// https://html.spec.whatwg.org/multipage/interactive-elements.html#the-summary-element
HTML_CONTAINER_ELEMENT(summary)

// =============================================================================
// Web Components Elements
// =============================================================================

// https://html.spec.whatwg.org/multipage/scripting.html#the-slot-element
HTML_CONTAINER_ELEMENT(slot)

// https://html.spec.whatwg.org/multipage/scripting.html#the-template-element
HTML_CONTAINER_ELEMENT(template_)

// Clean up macros to avoid polluting the global namespace
#undef HTML_VOID_ELEMENT
#undef HTML_CONTAINER_ELEMENT
#undef HTML_COMPACT_ELEMENT
#undef HTML_VOID_ATTR_ELEMENT

} // namespace sourcemeta::registry::html

#endif
