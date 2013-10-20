part of xmpp;

class StateResponse
{
  String CheckResponse;
  String SendRequest;
  StateResponse(this.CheckResponse,this.SendRequest);
}

class XmppConnection
{
  String _host;
  int _port;
  int _state = 0; // TODO make enum
  Socket _socket = null;

  Completer _completer;
  XmppConnection(String host, int port)
  {
    _host = host;
    _port = port;
    _stateResponses =  
        [ new StateResponse('','<stream:stream xmlns:stream="http://etherx.jabber.org/streams" version="1.0" xmlns="jabber:client" to="$_host" xml:lang="en" xmlns:xml="http://www.w3.org/XML/1998/namespace">'),        
          new StateResponse('stream:stream',''),
          new StateResponse('X-FACEBOOK-PLATFORM','<starttls xmlns="urn:ietf:params:xml:ns:xmpp-tls"/>'),
          new StateResponse('proceed','<stream:stream xmlns:stream="http://etherx.jabber.org/streams" version="1.0" xmlns="jabber:client" to="chat.facebook.com" xml:lang="en" xmlns:xml="http://www.w3.org/XML/1998/namespace">'),
          new StateResponse('stream:stream',''),
          new StateResponse('X-FACEBOOK-PLATFORM','<auth xmlns="urn:ietf:params:xml:ns:xmpp-sasl" mechanism="X-FACEBOOK-PLATFORM"></auth>'),
          new StateResponse('challenge',''),
          new StateResponse('success','<stream:stream xmlns:stream="http://etherx.jabber.org/streams" version="1.0" xmlns="jabber:client" to="$_host" xml:lang="en" xmlns:xml="http://www.w3.org/XML/1998/namespace">'),
          new StateResponse('stream:stream',''),
          new StateResponse('stream:features','<iq type="set" id="3"><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"><resource>fb_xmpp_script</resource></bind></iq>'),          
          new StateResponse('jid','<iq type="set" id="4" to="chat.facebook.com"><session xmlns="urn:ietf:params:xml:ns:xmpp-session"/></iq>'),          
          new StateResponse('session','<presence />')   
        ]; 
  }
  
  var _stateResponses;
  
  void ProcessResponse(String response)
  {
    print('ProcessResponse');
    print (response);
    
//    // TODO
//    if (response.length > 0) {
//      print('xml parse...');
//      XmlElement myXmlTree = XML.parse(response);
//      print (myXmlTree.hasChildren);
//    }
    

    if (_state == -1) {
      return; // error
    }

    if (_state == 11) {
      _state++;
      _completer.complete();
      return;
    }
    
    if (_state == 12) {
      //print('presence info: $response');
      return;
    }

    var stateResponse = _stateResponses[_state];
    
    if (stateResponse.CheckResponse.isEmpty || response.contains(stateResponse.CheckResponse)) {
      
      if (_state == 3) {
        SecureSocket.secure(_socket).then(
            (secureSocket) {
              _socket = secureSocket;
              _socket.transform(UTF8.decoder).listen(ProcessResponse);
              _state++;
              _socket.write(stateResponse.SendRequest);
            });
      }
      else if (_state == 6)
      {
        var challenge = response.substring(52); // TODO use a XML library
        challenge = challenge.substring(0, challenge.length - 12);
        
        var bytes = CryptoUtils.base64StringToBytes(challenge);
        var str = new String.fromCharCodes(bytes);
        var uri = Uri.decodeFull(str);
        var method = uri.split('&')[1].substring(7);
        var nonce = uri.split('&')[2].substring(6);
        var inner = _getInnerChallengeResponse(method, nonce);
        var innerEncoded = CryptoUtils.bytesToBase64(inner.runes.toList());
        
        var challengeResponse = '<response xmlns="urn:ietf:params:xml:ns:xmpp-sasl">$innerEncoded</response>';
        _state++;
        _socket.write(challengeResponse);       
        
      }
      else
      {
        _state++;
        _socket.write(stateResponse.SendRequest);
      }
      
    }
    else
    {
      _state = -1;
      _completer.completeError("error");
          
    }        
  }
  
  String _getInnerChallengeResponse(String method, String nonce)
  {
    // TODO this is untested
    return 'method=$method&nonce=$nonce&call_id=0&v=1.0';
  }
    
  
  Future Open()
  {        

    _completer = new Completer();
    
    Socket.connect(_host, _port).then(
        (Socket socket) {
          _state=0;
          _socket = socket;
          
          socket.transform(UTF8.decoder).listen(ProcessResponse);
          
          ProcessResponse('');         

          });
    
    return _completer.future;
                              
  }
  
  void SendMessage(String fromUserId, String userId, String body)
  {
    var msg = '<message xmlns="urn:ietf:params:xml:ns:xmpp-stanzas" xml:lang="en" to="-$userId@chat.facebook.com" from="-$fromUserId@chat.facebook.com" type="chat"><body>$body</body></message>';
    _socket.write(msg);    
  }
  
  void Close()
  {
    _socket.write('</stream:stream>');
    _state = 0;
  }

  
  
}
  

