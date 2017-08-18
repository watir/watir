function(){
    var result = [];
    var options = arguments[0].options;
    for (var i = 0; i < options.length; i++) {
        var option = options[i];
        if (option.selected) {
            result.push(option)
        }
    }
    return result;
}
