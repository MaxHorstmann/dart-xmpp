// A lightweight XMPP client for Dart.
// Contains additional support for Facebook chat server "xmpp"
// See README.md for more info on features and limitations.

library xmpp;

import "dart:io";
import "dart:async";
import "dart:convert";
import 'package:crypto/crypto.dart';
import "package:xml/xml.dart";

part 'src/xmpp_connection.dart';
part 'src/xmpp_facebookConnection.dart';

/**
* Utility class to create a new XMPP connection.
*/
class Xmpp {

  /**
  * Returns newly created Xmpp connection. 
  */
  static XmppConnection CreateXmppConnection(String server, int port)
  {
    return new XmppConnection(server, port);
  }
  
  /**
  * Returns newly created Facebook "Xmpp" connection. 
  * Facebook chat (chat.facebook.com) implements a modified subset
  * of the xmpp protocol. In particular, an access token needs to be 
  * acquired using the Facebook graph API before a connection to the
  * Facebook chat server can be made.  
  */
  static FacebookXmppConnection CreateFacebookXmppConnection(String app_id, String access_token)
  {
    return new FacebookXmppConnection("chat.facebook.com", 5222, app_id, access_token);
  }
  
}



