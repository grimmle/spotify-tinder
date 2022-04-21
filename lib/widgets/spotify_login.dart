import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

var scopes = [
  // 'ugc-image-upload',
  // 'playlist-modify-private',
  // 'playlist-read-private',
  // 'playlist-modify-public',
  // 'playlist-read-collaborative',
  'user-read-private',
  'user-read-email',
  // 'user-read-playback-state',
  // 'user-modify-playback-state',
  // 'user-read-currently-playing',
  // 'user-library-modify',
  // 'user-library-read',
  // 'user-read-playback-position',
  'user-read-recently-played',
  'user-top-read',
  // 'app-remote-control',
  // 'streaming',
  // 'user-follow-modify',
  // 'user-follow-read',
];

var url = dotenv.env['NODE_ENV'] == 'development' ? dotenv.env['DEV_URL'] : dotenv.env['PROD_URL'];

var uri = Uri.https("accounts.spotify.com", "/authorize", {
  "client_id": "0ccc3e74f2e44ffb9b8c87afb815dbf9",
  "response_type": "code",
  "redirect_uri": "$url/authorization-code-grant",
  "scope": scopes.join('%20'),
  "state": "",
});

// ignore: must_be_immutable
class SpotifyLogin extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late WebViewController controller;

  SpotifyLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Spotify Login'),
          backgroundColor: Color.fromRGBO(30, 215, 96, 1),
        ),
        child: WebView(
          initialUrl: uri.toString(),
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (controller) async {
            this.controller = controller;
            await controller.currentUrl();
          },
          navigationDelegate: (request) async {
            var url = dotenv.env['NODE_ENV'] == 'development' ? dotenv.env['DEV_URL'] : dotenv.env['PROD_URL'];
            if (request.url.startsWith('$url/callback?')) {
              var token =
                  request.url.substring(request.url.indexOf('token=') + 6, request.url.indexOf('&refresh_token='));
              var refreshToken = request.url.substring(request.url.indexOf('&refresh_token=') + 15);
              // print('TOKEN: $token');
              // print('REFRESH TOKEN: $refreshToken');

              if (token.isNotEmpty) {
                final User? user = auth.currentUser;
                final String? uid = user?.uid;
                // print('UID: $uid');

                var me = await http
                    .get(Uri.parse('$url/me'), headers: {
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                      'Authorization': 'Bearer $token',
                    })
                    .then((res) => jsonDecode(res.body))
                    .then((json) => json);
                var name = me['display_name'];
                var imgUrl = me['images'][0]['url'];
                Future.wait(<Future>[
                  SecureStorage.setLoggedInName(name),
                  SecureStorage.setLoggedInImg(imgUrl),
                  SecureStorage.setToken(token),
                  SecureStorage.setRefreshToken(refreshToken)
                ]).then((value) async => {
                      print('tokens saved'),
                      await FirebaseFirestore.instance.collection('users').doc(uid).set({
                        'token': token,
                        'refreshToken': refreshToken,
                        'displayName': name,
                        'img': imgUrl,
                      }, SetOptions(merge: true)),
                      Navigator.pushReplacementNamed(context, "/")
                    });
              }
            }
            return NavigationDecision.navigate;
          },
        ));
  }
}
