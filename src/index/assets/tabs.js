const tabButtons = document.querySelectorAll("[data-sourcemeta-ui-tab-target]");
const tabViews = document.querySelectorAll("[data-sourcemeta-ui-tab-id]");

function selectTab(tab, name) {
  tabButtons.forEach(element => element.classList.remove("active"));
  tab.classList.add("active");
  tabViews.forEach((panel) => {
    if (panel.getAttribute("data-sourcemeta-ui-tab-id") === name) {
      panel.classList.remove("d-none");
    } else {
      panel.classList.add("d-none");
    }
  });

  const url = new URL(window.location);
  url.searchParams.set("tab", name);
  window.history.replaceState({}, "", url);
}

const initialTab = new URL(window.location).searchParams.get("tab");
if (initialTab) {
  tabButtons.forEach((element) => {
    if (element.getAttribute("data-sourcemeta-ui-tab-target") === initialTab) {
      selectTab(element, initialTab);
    }
  });
} else if (tabButtons[0]) {
  selectTab(tabButtons[0], tabButtons[0].getAttribute("data-sourcemeta-ui-tab-target"));
}

tabButtons.forEach((tab) => {
  tab.addEventListener("click", () => {
    const targetId = tab.getAttribute("data-sourcemeta-ui-tab-target");
    selectTab(tab, targetId);
  });
});
