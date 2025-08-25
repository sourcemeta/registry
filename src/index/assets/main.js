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
    const pointers = JSON.parse(element.getAttribute('data-sourcemeta-ui-editor-highlight-pointers'));
    if (EDITORS[url]) {
      const positions = await window.fetch(`/api/schemas/positions${url.replace(/\.json$/i, "")}`);
      if (!positions.ok) {
        throw new Error(positions.statusText);
      }

      const positions_json = await positions.json();
      EDITORS[url].unhighlight();
      const mainRange = positions_json[pointers[0]];
      EDITORS[url].highlight(mainRange, "#fb9c9c");
      EDITORS[url].scroll(mainRange[0]);
      for (const pointer of pointers.slice(1)) {
        const range = positions_json[pointer];
        EDITORS[url].highlight(range, "#ffedd0");
      }
    }
  });
});
