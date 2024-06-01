import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:simple_mail/services/send_email.dart';
import 'package:simple_mail/ui/widgets/custom_text_field.dart';
import 'sign_in_page.dart';

class MailPage extends StatefulWidget {
  final User user;
  final GoogleSignInAuthentication googleAuth;

  const MailPage({super.key, required this.user, required this.googleAuth});

  @override
  MailPageState createState() => MailPageState();
}

class MailPageState extends State<MailPage> {
  final _recipientController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  final EmailSender _emailSender = EmailSender();

  Future<void> _sendEmail() async {
    final recipient = _recipientController.text;
    final subject = _subjectController.text;
    final body = _bodyController.text;

    if (recipient.isEmpty || subject.isEmpty || body.isEmpty) {
      // Show an error message if any field is empty
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('All fields are required.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      await _emailSender.sendEmail(
        widget.googleAuth.accessToken!,
        recipient,
        subject,
        body,
      );
      // Show success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Email sent successfully!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Show error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to send email: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // This removes the back arrow
        title: const Text('Mail Page'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout, color: Colors.black54),
              label:
                  const Text('Logout', style: TextStyle(color: Colors.black54)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${widget.user.displayName}!'),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _recipientController,
              labelText: 'Recipient',
              hintText: 'Enter recipient email',
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _subjectController,
              labelText: 'Subject',
              hintText: 'Enter email subject',
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _bodyController,
              labelText: 'Body',
              hintText: 'Enter email body',
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Send Email'),
            ),
          ],
        ),
      ),
    );
  }
}
