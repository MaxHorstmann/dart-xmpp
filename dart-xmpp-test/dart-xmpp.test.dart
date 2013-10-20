import "package:xmpp/xmpp.dart" as xmpp;

void main() {  
  testFacebookXmpp();
}


void testFacebookXmpp() {
  
  // Go to https://developers.facebook.com/tools/explorer and get
  // an identifier (a.k.a. AppId) and an access token. 
  // Make sure to grant xmpp_login permission.
  var identifier = "208491562633548";
  var accessToken = "CAAC9nzmHiUwBAPpD27KStrhfHIv0PQz1IMWXIiZBCP3O1c08w2LvRPUXCZCm3FTX92tUOZCmNjVL594GwU9P7f5fybdiRtt7UF7NJH2bBhxlMw6CJHqcuZBxaonD3MyC7qLK8xVUvcxaZC7ArvBsCctMaGmJ66rUkKbItzVTC4kUXKYrvmyXmppI1iTCGRWEcXCvAJdi3LAZDZD";
  
  print("Testing xmpp connection to Facebook chat...");
  var conn = xmpp.Xmpp.CreateFacebookXmppConnection(identifier, accessToken);
  
  conn.Open()
    .then(
      (foo) {
        print("connection open...");
        //conn.SendPresence();
        print("success!");
      })
  .catchError(
      (e) {
        print("Error: $e");
      });
    
  
}
