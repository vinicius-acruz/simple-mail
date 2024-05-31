import 'dart:convert';
import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class EmailSender {
  final String _clientId = 'YOUR_CLIENT_ID';
  final String _gmailSendScope = 'https://www.googleapis.com/auth/gmail.send';

  Future<void> sendEmail(
      User user, String recipient, String subject, String body) async {
    // Obtain the user's ID token from Firebase Authentication
    final idToken = await user.getIdToken();
    print('$idToken');

    // Create the authenticated client with the ID token
    final client = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken(
            'Bearer', idToken!, DateTime.now().toUtc().add(Duration(hours: 1))),
        null,
        [_gmailSendScope],
      ),
    );

    final gmailApi = GmailApi(client);

    final message = Message()
      ..raw = base64Url.encode(utf8.encode('To: $recipient\r\n'
          'Subject: $subject\r\n\r\n'
          '$body'));

    try {
      await gmailApi.users.messages.send(message, 'me');
      print('Email sent!');
    } catch (e) {
      print('Error sending email: $e');
    } finally {
      client.close();
    }
  }
}
