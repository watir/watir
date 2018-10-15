// Original Author: Florent B.
// Source: https://stackoverflow.com/a/45244889/1200545
function() {
    var elem = arguments[0],
        box = elem.getBoundingClientRect(),
        cx = box.left + box.width / 2,
        cy = box.top + box.height / 2,
        e = document.elementFromPoint(cx, cy);
    for (; e; e = e.parentElement) {
        if (e === elem)
            return false;
    }
    return true;
}