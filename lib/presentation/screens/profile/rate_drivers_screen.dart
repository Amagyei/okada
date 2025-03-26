
import 'package:flutter/material.dart';
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';

class DriverRating {
  final String name;
  final String tripDate;
  final String tripRoute;
  final String imageUrl;
  double rating;
  String? feedback;

  DriverRating({
    required this.name,
    required this.tripDate,
    required this.tripRoute,
    required this.imageUrl,
    this.rating = 0,
    this.feedback,
  });
}

class RateDriversScreen extends StatefulWidget {
  @override
  _RateDriversScreenState createState() => _RateDriversScreenState();
}

class _RateDriversScreenState extends State<RateDriversScreen> {
  final List<DriverRating> _pendingRatings = [
    DriverRating(
      name: 'Emmanuel Osei',
      tripDate: 'Yesterday, 2:15 PM',
      tripRoute: 'Accra Mall to Osu',
      imageUrl: 'assets/driver1.png',
    ),
    DriverRating(
      name: 'Kofi Manu',
      tripDate: 'Yesterday, 10:40 AM',
      tripRoute: 'Legon to Circle',
      imageUrl: 'assets/driver2.png',
    ),
  ];

  final List<DriverRating> _completedRatings = [
    DriverRating(
      name: 'Francis Boateng',
      tripDate: '20 May, 4:30 PM',
      tripRoute: 'Tema to Accra',
      imageUrl: 'assets/driver3.png',
      rating: 4.5,
      feedback: 'Great service, very timely and polite',
    ),
    DriverRating(
      name: 'John Mensah',
      tripDate: '18 May, 1:15 PM',
      tripRoute: 'Airport to East Legon',
      imageUrl: 'assets/driver4.png',
      rating: 5.0,
      feedback: 'Excellent ride, very professional',
    ),
  ];

  void _submitRating(DriverRating driver, double rating, String? feedback) {
    setState(() {
      driver.rating = rating;
      driver.feedback = feedback;
      _pendingRatings.remove(driver);
      _completedRatings.add(driver);
    });
  }

  void _showRatingDialog(DriverRating driver) {
    double rating = driver.rating;
    final feedbackController = TextEditingController(text: driver.feedback);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate Your Driver'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: ghanaGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    color: ghanaGold,
                  ),
                ),
              ),
              title: Text(driver.name),
              subtitle: Text(driver.tripRoute),
            ),
            SizedBox(height: 20),
            Text('How was your experience?'),
            SizedBox(height: 10),
            StatefulBuilder(
              builder: (context, setDialogState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating.floor() ? Icons.star : (index < rating ? Icons.star_half : Icons.star_border),
                        color: ghanaGold,
                        size: 32,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          rating = index + 1.0;
                        });
                      },
                    );
                  }),
                );
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: feedbackController,
              decoration: InputDecoration(
                hintText: 'Add feedback (optional)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ghanaGreen,
            ),
            onPressed: () {
              _submitRating(driver, rating, feedbackController.text.isEmpty ? null : feedbackController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Thank you for your feedback!'),
                  backgroundColor: ghanaGreen,
                ),
              );
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate Drivers'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'Pending (${_pendingRatings.length})'),
                Tab(text: 'Completed (${_completedRatings.length})'),
              ],
              labelColor: ghanaGreen,
              unselectedLabelColor: textSecondary,
              indicatorColor: ghanaGreen,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPendingRatingsTab(),
                  _buildCompletedRatingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRatingsTab() {
    return _pendingRatings.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.thumb_up_alt_outlined,
                  size: 80,
                  color: textHint,
                ),
                SizedBox(height: 16),
                Text(
                  'No pending ratings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _pendingRatings.length,
            itemBuilder: (context, index) {
              final driver = _pendingRatings[index];
              return GhanaCard(
                padding: EdgeInsets.all(16),
                elevation: 1,
                onTap: () => _showRatingDialog(driver),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: ghanaGold.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person,
                              color: ghanaGold,
                              size: 30,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driver.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                driver.tripDate,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                driver.tripRoute,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    GhanaButton(
                      text: 'Rate Driver',
                      onPressed: () => _showRatingDialog(driver),
                      width: double.infinity,
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildCompletedRatingsTab() {
    return _completedRatings.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 80,
                  color: textHint,
                ),
                SizedBox(height: 16),
                Text(
                  'No completed ratings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _completedRatings.length,
            itemBuilder: (context, index) {
              final driver = _completedRatings[index];
              return GhanaCard(
                padding: EdgeInsets.all(16),
                elevation: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: ghanaGold.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person,
                              color: ghanaGold,
                              size: 30,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driver.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                driver.tripDate,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                driver.tripRoute,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < driver.rating.floor() 
                              ? Icons.star 
                              : (index < driver.rating ? Icons.star_half : Icons.star_border),
                          color: ghanaGold,
                          size: 20,
                        );
                      }),
                    ),
                    if (driver.feedback != null && driver.feedback!.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        driver.feedback!,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
  }
}
