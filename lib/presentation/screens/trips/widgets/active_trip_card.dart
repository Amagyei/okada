import 'package:flutter/material.dart';
import '../../../../core/constants/theme.dart';
import '../../../../core/widgets/ghana_widgets.dart';

class ActiveTripCard extends StatelessWidget {
  final String from;
  final String to;
  final String driverName;
  final double driverRating;
  final String eta;
  final VoidCallback onCancel;

  const ActiveTripCard({
    Key? key,
    required this.from,
    required this.to,
    required this.driverName,
    required this.driverRating,
    required this.eta,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Map view placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Text(
                'Live Trip Map',
                style: TextStyle(
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Status indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: ghanaGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: ghanaGold,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Driver is on the way',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ghanaGoldLight ?? Colors.brown,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Trip details
                Row(
                  children: [
                    Container(
                      width: 32,
                      child: Column(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: ghanaGreen,
                          ),
                          Container(
                            height: 30,
                            width: 1,
                            color: Colors.grey.shade300,
                          ),
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: ghanaRed,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            from,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            to,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // ETA
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Estimated arrival in ',
                      style: TextStyle(
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      eta,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ghanaGreen,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // Driver info
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey.shade100,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: ghanaGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            driverName.substring(0, 1),
                            style: TextStyle(
                              fontSize: 20,
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
                              driverName,
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
                                  '$driverRating',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  'Yamaha',
                                  style: TextStyle(
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ghanaGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.phone,
                          color: ghanaGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: Icon(Icons.close),
                        label: Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: ghanaRed,
                          side: BorderSide(color: ghanaRed),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Message driver
                        },
                        icon: Icon(Icons.message),
                        label: Text('Message'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
