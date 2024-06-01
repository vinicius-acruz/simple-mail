import 'dart:convert';
import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class EmailSender {
  final List<String> _scopes = [GmailApi.gmailSendScope];

  Future<void> sendEmail(
      String accessToken, String recipient, String subject, String body) async {
    // Create the authenticated client with the access token
    final client = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken('Bearer', accessToken,
            DateTime.now().toUtc().add(const Duration(hours: 1))),
        null,
        _scopes,
      ),
    );

    final gmailApi = GmailApi(client);

    // Create the MIME message
    final message = Message()
      ..raw = base64Url.encode(utf8.encode('To: $recipient\r\n'
          'Subject: $subject\r\n'
          'Content-Type: text/plain; charset="utf-8"\r\n'
          '\r\n'
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
