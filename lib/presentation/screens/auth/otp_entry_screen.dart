import 'dart:async'; // Import Timer
import 'package:flutter/material.dart';
import 'package:okada_app/core/services/auth_service.dart';
import 'package:okada_app/routes.dart'; // Ensure AppRoutes is imported

class OtpEntryScreen extends StatefulWidget {
  final String phoneNumber; // Receive phone number

  const OtpEntryScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _OtpEntryScreenState createState() => _OtpEntryScreenState();
}

class _OtpEntryScreenState extends State<OtpEntryScreen> {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService(); // Instance of AuthService
  bool _isLoading = false;
  bool _isResending = false;
  bool _canResend = false;
  Timer? _resendTimer;
  int _resendCooldown = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _authService.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _showError(String message) {
     if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _startResendTimer() {
    _canResend = false;
    _resendTimer?.cancel();
    setState(() { _resendCooldown = 60; });

    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
       if (!mounted) {
         timer.cancel();
         return;
       }
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          _canResend = true; 
          timer.cancel();
        }
      });
    });
  }



  Future<void> _submitOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showError('Please enter a valid 6-digit OTP');
      return;
    }

    setState(() { _isLoading = true; });

    try {
      await _authService.verifyOtp(otp);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      }
    } catch (e) {
       if (mounted) {
         _showError(e.toString().replaceFirst("Exception: ", ""));
       }
    } finally {
       if (mounted) {
         setState(() { _isLoading = false; });
       }
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return; // Prevent resend during cooldown

    setState(() { _isResending = true; });

    try {
      // Call requestOtp using the phone number passed to the screen
      await _authService.requestOtp(phoneNumber: widget.phoneNumber);

      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('New OTP requested successfully'), backgroundColor: Colors.green),
         );
        _startResendTimer(); // Restart the cooldown timer
      }
    } catch (e) {
       if (mounted) {
         _showError(e.toString().replaceFirst("Exception: ", ""));
       }
    } finally {
       if (mounted) {
         setState(() { _isResending = false; });
       }
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
              'Enter the 6-digit OTP sent to ${widget.phoneNumber}', // Show phone number
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, letterSpacing: 8), // Style for better OTP look
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '------', // Hint text
                counterText: '',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitOtp, // Disable while loading
              child: _isLoading
                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Submit OTP'),
            ),
            SizedBox(height: 15),
            TextButton(
              // Enable/disable based on _canResend, show loading indicator
              onPressed: _canResend && !_isResending ? _resendOtp : null,
              child: _isResending
                  ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      _canResend
                          ? 'Resend OTP'
                          : 'Resend OTP in $_resendCooldown s',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}