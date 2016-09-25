var WatirSpec = function() {
    
  return {
    addMessage: function(string) {
        var text = document.createTextNode(string)
        var message = document.createElement('div');
        var messages = document.getElementById('messages');

        message.appendChild(text)
        messages.appendChild(message);
    }
  };
  
    
}(); // WatirSpec

