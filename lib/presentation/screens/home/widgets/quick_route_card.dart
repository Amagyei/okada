import 'package:flutter/material.dart';
import '../../../../core/constants/theme.dart';

class QuickRouteCard extends StatelessWidget {
  final String from;
  final String to;
  final String price;
  final String time;
  final String? popularity;
  final VoidCallback onTap;

  const QuickRouteCard({
    super.key,
    required this.from,
    required this.to,
    required this.price,
    required this.time,
    this.popularity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: ghanaGreen,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      from,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 4),
                child: Container(
                  height: 20,
                  width: 1,
                  color: textHint,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 12,
                    color: ghanaRed,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      to,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              if (popularity != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ghanaGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    popularity!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: ghanaGoldDark ?? Colors.brown,
                    ),
                  ),
                ),
                SizedBox(height: 12),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ghanaGreen,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
