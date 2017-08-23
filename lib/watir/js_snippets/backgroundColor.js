function(){
    if(arguments[1]) {
        arguments[0].style.backgroundColor = arguments[1];
    } else {
        return arguments[0].style.backgroundColor;
    }
}
