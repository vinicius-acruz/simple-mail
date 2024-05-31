import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'send_email.dart';

class MailPage extends StatelessWidget {
  final User user;

  MailPage({required this.user});

  final EmailSender _emailSender = EmailSender();

  Future<void> _sendEmail() async {
    await _emailSender.sendEmail(
      user,
      'vini.allves@hotmail.com',
      'Test Subject',
      'Test Body',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Success'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user.displayName}!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendEmail,
              child: Text('Send Test Email'),
            ),
          ],
        ),
      ),
    );
  }
}
