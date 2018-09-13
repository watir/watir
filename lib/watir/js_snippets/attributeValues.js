// Original Author: Justin Ko
// Source: https://stackoverflow.com/questions/12485833/how-do-i-retrieve-list-of-element-attributes-using-watir-webdriver
function() {
    var s = {};
    var attrs = arguments[0].attributes;
    for (var l = 0; l < attrs.length; ++l) {
        var a = attrs[l];
        s[a.name] = a.value.trim();
    }
    return s;
}