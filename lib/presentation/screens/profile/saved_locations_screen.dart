
import 'package:flutter/material.dart';
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';

class SavedLocation {
  final String name;
  final String address;
  final IconData icon;

  SavedLocation({required this.name, required this.address, required this.icon});
}

class SavedLocationsScreen extends StatefulWidget {
  @override
  _SavedLocationsScreenState createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  final List<SavedLocation> _locations = [
    SavedLocation(
      name: 'Home',
      address: '123 Cantonments Road, Accra',
      icon: Icons.home_outlined,
    ),
    SavedLocation(
      name: 'Work',
      address: 'Independence Avenue, Accra',
      icon: Icons.work_outline,
    ),
    SavedLocation(
      name: 'University',
      address: 'University of Ghana, Legon',
      icon: Icons.school_outlined,
    ),
  ];

  void _showAddLocationDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GhanaTextField(
              label: 'Location Name',
              controller: nameController,
              hint: 'E.g. Home, Work, Gym',
              prefixIcon: Icons.place_outlined,
            ),
            SizedBox(height: 16),
            GhanaTextField(
              label: 'Address',
              controller: addressController,
              hint: 'Enter address',
              prefixIcon: Icons.map_outlined,
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
              if (nameController.text.isNotEmpty && addressController.text.isNotEmpty) {
                setState(() {
                  _locations.add(
                    SavedLocation(
                      name: nameController.text,
                      address: addressController.text,
                      icon: Icons.place_outlined,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Locations'),
      ),
      body: _locations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 80,
                    color: textHint,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No saved locations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add locations for quicker booking',
                    style: TextStyle(
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final location = _locations[index];
                return Dismissible(
                  key: Key(location.name + index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    color: ghanaRed,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      _locations.removeAt(index);
                    });
                  },
                  child: GhanaCard(
                    padding: EdgeInsets.all(16),
                    elevation: 1,
                    onTap: () {
                      // Edit location
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: ghanaGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            location.icon,
                            color: ghanaGold,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                location.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                location.address,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: textSecondary,
                          ),
                          onPressed: () {
                            // Edit location
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ghanaGreen,
        child: Icon(Icons.add),
        onPressed: _showAddLocationDialog,
      ),
    );
  }
}