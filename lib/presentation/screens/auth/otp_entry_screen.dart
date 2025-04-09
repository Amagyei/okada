import 'package:flutter/material.dart';

class OtpEntryScreen extends StatefulWidget {
  @override
  _OtpEntryScreenState createState() => _OtpEntryScreenState();
}

class _OtpEntryScreenState extends State<OtpEntryScreen> {
  final TextEditingController _otpController = TextEditingController();

  void _submitOtp() {
    final otp = _otpController.text;
    if (otp.length == 6) {
      // Handle OTP submission
      print("OTP Submitted: $otp");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter the 6-digit OTP sent to your phone',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter OTP',
                counterText: '',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitOtp,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}