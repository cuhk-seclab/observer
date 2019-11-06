function traverseTree() {

  function visitChildren(e) {
    var observerLog = e.observerLog;
    var initiator = e.initiator;
    var nid = e.nid;
    if (e.localName == "script") {
      var scriptID  = e.scriptID;
      var parentScriptID = e.parentScriptID;
    }
    var style = window.getComputedStyle(e);
    var displayInfo = new Object();
    displayInfo.display = style.display != "none";
    if (displayInfo.display == true) {
      var elemRect = e.getBoundingClientRect();
      displayInfo.top = elemRect.top + pageYOffset;
      displayInfo.left = elemRect.left + pageXOffset;
      displayInfo.width = elemRect.width;
      displayInfo.height = elemRect.height;
      displayInfo.opacity = style.opacity;
      displayInfo.visibility = style.visibility != "hidden";
      displayInfo.position = style.position;
      displayInfo.zIndex = style.zIndex;

      e.setAttribute("displayInfo", JSON.stringify(displayInfo));
    }
    var children = e.children;
    for (var i = 0; i < children.length; ++i) {
      visitChildren(children[i]);
    }
  }

  visitChildren(document.documentElement);

  var scriptidmap = document.scriptIDMap;

  var result = {"scriptidmap": scriptidmap};
  return result;
}

return traverseTree();
