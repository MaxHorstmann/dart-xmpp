part of xmpp;

class FacebookXmppConnection extends XmppConnection
{
  
  String _app_id;
  String _access_token;
    
  FacebookXmppConnection(String host, int port, String app_id, String access_token)
      : super(host, port)
  {
    _app_id = app_id;
    _access_token = access_token;
  }
  
  String _getInnerChallengeResponse(String method, String nonce)
  {
    return 'method=$method&nonce=$nonce&access_token=$_access_token&api_key=$_app_id&call_id=0&v=1.0';
  }

  
}
  

