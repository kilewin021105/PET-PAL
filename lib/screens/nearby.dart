import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  final List<Map<String, dynamic>> _places = [
    {
      'name': 'Bohol Veterinary Clinic',
      'type': 'Pet Store',
      'distance': 'Varies',
      'address': 'Island City Mall, Rajah Sikatuna Ave',
      'open': 'Open • Closes 6 PM',
      'phone': '+63 923 614 7554',
    },
    {
      'name': 'Orig VetCare Animal Clinic',
      'type': 'Vet',
      'distance': 'Varies',
      'address': 'Penaflor St',
      'open': 'Open • Closes 9 PM',
      'phone': '+63 960 201 6523',
    },
    {
      'name': 'Venancio P. Inting Veterinary Care',
      'type': 'Vet',
      'distance': 'Varies',
      'address': '0112 Venancio P. Inting Avenue',
      'open': 'Open • Closes 6:30 PM',
      'phone': '+63 951 132 8278',
    },
    {
      'name': 'J.A. Clarin Pet Supply Store',
      'type': 'Pet Store',
      'distance': 'Varies',
      'address': 'J.A. Clarin St',
      'open': 'Open • Closes 6:30 PM',
      'phone': '+63 960 327 1491',
    },
    {
      'name': 'Paws Domain Veterinary Clinic & Grooming Center',
      'type': 'Vet',
      'distance': 'Varies',
      'address': 'Amira Land Corporate Center, 0362 Jose Go St.',
      'open': 'Open • Closes 5:30 PM',
      'phone': '+63 918 623 2290',
    },
    {
      'name': 'Egos Agrivet & Veterinary Clinic',
      'type': 'Vet',
      'distance': 'Varies',
      'address': 'JVV3+3RG, B. Inting Street',
      'open': 'Open • Closes 6 PM',
      'phone': '+63 38 412 3725',
    },
    {
      'name': 'AnimalZone Veterinary Clinic',
      'type': 'Vet',
      'distance': 'Varies',
      'address': 'Purok 2',
      'open': 'Open • Closes 6 PM',
      'phone': '+63 915 506 4967',
    },
    {
      'name': 'REFUGIO VETERINARY CLINIC',
      'type': 'Vet',
      'distance': 'Varies',
      'address': 'Pooc Occidental Barangay Rd',
      'open': 'Open • Closes 5 PM',
      'phone': '+63 929 223 9103',
    },
    {
      'name': 'Seaside Veterinary Clinic',
      'type': 'Vet',
      'distance': 'Varies',
      'address': 'Venancio P. Inting Avenue',
      'open': 'Open • Closes 6 PM',
      'phone': '+63 981 664 5204',
    },
    {
      'name': 'Carlos P. Garcia Pet Store',
      'type': 'Pet Store',
      'distance': 'Varies',
      'address': '35 Carlos P. Garcia East Avenue',
      'open': 'Open • Closes 5 PM',
      'phone': '+63 38 411 1154',
    },
  ];

  List<Map<String, dynamic>> get _filteredPlaces {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _places;
    return _places
        .where((p) =>
            (p['name'] as String).toLowerCase().contains(q) ||
            (p['type'] as String).toLowerCase().contains(q) ||
            (p['address'] as String).toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'vet':
        return Colors.redAccent;
      case 'pet store':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> _openGoogleMaps(String address) async {
    final query = Uri.encodeComponent(address + ', Bohol, Philippines');
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  Future<void> _makeCall(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not make call')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Pet Stores & Vets in Bohol'),
        backgroundColor: Colors.grey,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search by name, type, or address',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Results header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Results',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '${_filteredPlaces.length} places',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Results list
          ..._filteredPlaces.map((p) {
            final type = p['type'] as String;
            final color = _typeColor(type);
            final phone = p['phone'] as String;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: color.withOpacity(0.1),
                        child: Icon(
                          type.toLowerCase() == 'vet'
                              ? Icons.local_hospital
                              : Icons.storefront,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: color.withOpacity(0.12),
                                  ),
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.place, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  p['distance'] as String,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p['address'] as String,
                              style: const TextStyle(color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p['open'] as String,
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _makeCall(phone),
                        icon: const Icon(Icons.call, size: 18),
                        label: const Text('Call'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _openGoogleMaps(p['address'] as String),
                        icon: const Icon(Icons.directions, size: 18),
                        label: const Text('Directions'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          const Text(
            'Tip: These are static places in Bohol. Enable location permissions and integrate a map plugin (e.g., Google Maps) to show live places nearby.',
            style: TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }
}