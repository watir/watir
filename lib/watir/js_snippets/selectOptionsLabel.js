function(){
    for(var i=0; i<arguments[0].options.length; i++) {
        if ( arguments[0].options[i].label.match(arguments[1]) ) {
            arguments[0].options[i].selected = true;
            if ( arguments[2] == 'single' ) {
                break;
            }
        }
    }
}
