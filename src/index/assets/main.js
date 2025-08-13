import "./tabs.js";
import "./search.js";

import { Editor } from "./editor.js";

document.querySelectorAll('[data-sourcemeta-ui-editor]').forEach(async (element) => {
  const url = element.getAttribute('data-sourcemeta-ui-editor');
  const response = await window.fetch(url);
  if (response.ok) {
    element.innerHTML = "";
    new Editor(element, await response.text(), {
      readOnly: element.getAttribute('data-sourcemeta-ui-editor-mode') == "readonly",
      json: element.getAttribute('data-sourcemeta-ui-editor-language') == "json"
    });
  } else {
    throw new Error(response.statusText);
  }
});
