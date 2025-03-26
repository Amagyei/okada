
import 'package:flutter/material.dart';
import '../../../../core/constants/theme.dart';

class DriverCard extends StatelessWidget {
  final String name;
  final double rating;
  final String price;
  final String eta;
  final bool isSelected;
  final VoidCallback onTap;

  const DriverCard({
    Key? key,
    required this.name,
    required this.rating,
    required this.price,
    required this.eta,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? ghanaGreen.withOpacity(0.05) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ghanaGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Driver avatar placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: ghanaGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.substring(0, 1),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ghanaGreen,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: ghanaGold,
                      ),
                      SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(
                        Icons.motorcycle_outlined,
                        size: 16,
                        color: textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Yamaha',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: ghanaGreen,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'ETA: $eta',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                color: ghanaGreen,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
