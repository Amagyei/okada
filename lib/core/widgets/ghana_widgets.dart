import 'package:flutter/material.dart';
import '../constants/theme.dart';

class GhanaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double width;

  const GhanaButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ghanaGreen, Color(0xFF008E53)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: ghanaGreen.withOpacity(0.25),
            offset: Offset(0, 4),
            blurRadius: 8.0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: ghanaWhite,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class KenteBorderContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderWidth;

  KenteBorderContainer({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: ghanaGold,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Kente pattern decoration (stylized as a container)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: KentePatternPainter(),
              ),
            ),
          ),
          // Actual content
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}

// Custom painter for Kente pattern
class KentePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // This is a simplified representation of kente pattern
    // Using basic shapes and colors to simulate the pattern
    final Paint paint = Paint();
    
    // Draw horizontal stripes
    double stripeHeight = size.height / 10;
    List<Color> colors = [
      kenteYellow.withOpacity(0.2),
      kenteGreen.withOpacity(0.2),
      kenteRed.withOpacity(0.2),
      kenteBlue.withOpacity(0.2),
    ];
    
    for (int i = 0; i < 10; i++) {
      paint.color = colors[i % colors.length];
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeHeight, size.width, stripeHeight),
        paint,
      );
    }
    
    // Add vertical accents
    paint.color = ghanaBlack.withOpacity(0.1);
    double accentWidth = size.width / 20;
    for (int i = 0; i < 20; i += 2) {
      canvas.drawRect(
        Rect.fromLTWH(i * accentWidth, 0, accentWidth, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GhanaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final VoidCallback? onTap;

  const GhanaCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.elevation = 2,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class LoadingBike extends StatefulWidget {
  final double size;
  final Color color;

  const LoadingBike({
    Key? key,
    this.size = 60,
    this.color = ghanaGreen,
  }) : super(key: key);

  @override
  _LoadingBikeState createState() => _LoadingBikeState();
}

class _LoadingBikeState extends State<LoadingBike>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _bikeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _bikeAnimation = Tween<Offset>(
      begin: Offset(-0.2, 0),
      end: Offset(0.2, -0.1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Road line
          Positioned(
            bottom: widget.size * 0.3,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              color: widget.color.withOpacity(0.3),
            ),
          ),
          // Motorcycle emoji with animation
          SlideTransition(
            position: _bikeAnimation,
            child: Text(
              '🏍️',
              style: TextStyle(
                fontSize: widget.size * 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GhanaTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool readOnly; 
  final bool enabled;  

  const GhanaTextField({
    Key? key,
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffix,
    this.readOnly = false, 
    this.enabled = true,   
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: enabled ? textPrimary : textSecondary.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          readOnly: readOnly,   
          enabled: enabled, 
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: enabled ? null : textSecondary.withOpacity(0.6),
                  )
                : null,
            suffix: suffix,
          ),
        ),
      ],
    );
  }
}