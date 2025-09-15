var search = document.getElementById('search');
var searchResult = document.getElementById('search-result');
var hasSearchResults = false;

document.addEventListener('click', function(event) {
  if (!search.contains(event.target) && !searchResult.contains(event.target)) {
    searchResult.classList.add('d-none');
  }
});

search.addEventListener('focus', function() {
  if (hasSearchResults) {
    searchResult.classList.remove('d-none');
  }
});

function createChild(element, type, classes, content) {
  var child = document.createElement(type);
  child.className = classes;
  child.textContent = content;
  element.appendChild(child);
}

var timeout;
search.addEventListener('input', function(event) {
  clearTimeout(timeout);
  timeout = setTimeout(function() {
    if (!event.target.value) {
      searchResult.classList.add('d-none');
      return;
    }

    console.log('Searching for:', event.target.value);
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/self/api/schemas/search?q=' + encodeURIComponent(event.target.value));
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4 && xhr.status === 200) {
        var response = JSON.parse(xhr.responseText);
        searchResult.innerHTML = '';
        searchResult.classList.remove('d-none');
        if (response.length === 0) {
          hasSearchResults = false;
          var anchor = document.createElement('a');
          anchor.href = '#';
          anchor.className = 'list-group-item list-group-item-action disabled';
          anchor.setAttribute('aria-disabled', 'true');
          anchor.textContent = 'No results';
          searchResult.appendChild(anchor);
        } else {
          hasSearchResults = true;
          response.forEach(function(entry) {
            var anchor = document.createElement('a');
            anchor.href = entry.path;
            anchor.className = 'list-group-item list-group-item-action';
            createChild(anchor, 'small', 'font-monospace', entry.path);
            if (entry.title) {
              createChild(anchor, 'span', 'fw-bold d-block', entry.title);
            }
            if (entry.description) {
              createChild(anchor, 'small', 'text-secondary d-block', entry.description);
            }
            searchResult.appendChild(anchor);
          });
        }
        console.log(response);
      }
    };
    xhr.send();
  }, 300);
});
