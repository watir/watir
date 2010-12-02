// stolen from injectableSelenium.js in WebDriver
var browserbot = {
  createEventObject : function(element, controlKeyDown, altKeyDown, shiftKeyDown, metaKeyDown)  {
    var evt = element.ownerDocument.createEventObject();
        evt.shiftKey = shiftKeyDown;
        evt.metaKey = metaKeyDown;
        evt.altKey = altKeyDown;
        evt.ctrlKey = controlKeyDown;
        return evt;
    },

    triggerEvent: function(element, eventType, canBubble, controlKeyDown, altKeyDown, shiftKeyDown, metaKeyDown) {
        canBubble = (typeof(canBubble) == undefined) ? true: canBubble;
        if (element.fireEvent && element.ownerDocument && element.ownerDocument.createEventObject) {
            // IE
            var evt = this.createEventObject(element, controlKeyDown, altKeyDown, shiftKeyDown, metaKeyDown);
            element.fireEvent('on' + eventType, evt);
        } else {
            var evt = document.createEvent('HTMLEvents');

            try {
                evt.shiftKey = shiftKeyDown;
                evt.metaKey = metaKeyDown;
                evt.altKey = altKeyDown;
                evt.ctrlKey = controlKeyDown;
            } catch(e) {
                // Nothing sane to do
                }

            evt.initEvent(eventType, canBubble, true);
            return element.dispatchEvent(evt);
        }
    },

    getVisibleText: function() {
        var selection = getSelection();
        var range = document.createRange();
        range.selectNodeContents(document.documentElement);
        selection.addRange(range);
        var string = selection.toString();
        selection.removeAllRanges();

        return string;
    },

    getOuterHTML: function(element) {
        if (element.outerHTML) {
            return element.outerHTML;
        } else if (typeof(XMLSerializer) != undefined) {
            return new XMLSerializer().serializeToString(element);
        } else {
            throw "can't get outerHTML in this browser";
        }
    }


};