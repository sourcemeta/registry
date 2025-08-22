import "./tabs.js";
import "./search.js";

import { Editor } from "./editor.js";

const EDITORS = {};
document.querySelectorAll('[data-sourcemeta-ui-editor]').forEach(async (element) => {
  const url = element.getAttribute('data-sourcemeta-ui-editor');
  const response = await window.fetch(url);
  if (response.ok) {
    element.innerHTML = "";
    EDITORS[url] = new Editor(element, await response.text(), {
      readOnly: element.getAttribute('data-sourcemeta-ui-editor-mode') == "readonly",
      json: element.getAttribute('data-sourcemeta-ui-editor-language') == "json"
    });
  } else {
    throw new Error(response.statusText);
  }
});

document.querySelectorAll('[data-sourcemeta-ui-editor-highlight]').forEach((element) => {
  element.addEventListener("click", async (event) => {
    event.preventDefault();
    const url = element.getAttribute('data-sourcemeta-ui-editor-highlight');
    const pointer = element.getAttribute('data-sourcemeta-ui-editor-highlight-pointer');
    if (EDITORS[url]) {
      const positions = await window.fetch(`/api/schemas/positions${url.replace(/\.json$/i, "")}`);
      if (!positions.ok) {
        throw new Error(positions.statusText);
      }

      const range = (await positions.json())[pointer];
      EDITORS[url].unhighlight();
      EDITORS[url].highlight(range, "#fb9c9c");
      EDITORS[url].scroll(range[0]);
    }
  });
});
