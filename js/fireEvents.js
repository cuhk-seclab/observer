function traverseTree() {
  document.disableSensitiveAPIs(); // Disable the navigations caused by clicks in Observer
  var result = [];
  var nodes = document.querySelectorAll("*");
  for (var i = 0; i < nodes.length; ++i) {
    e = nodes[i];
    // XXX: It may take a very long time to click all elements!!!
    // Consider clicking only <a> elements and those with (click) EventListener
    if (e.tagName == "A" || ("click" in e && typeof(e["click"]) == "function")) {
      r = [e.nid];
      e.click();
      log = document.apiLog;
      if (log.length > 2) {
        r.push(log);
        result.push(r);
      }
    }
  }
  return result;
}

return traverseTree();
