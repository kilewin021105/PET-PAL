import 'healthEventCard.dart';
import 'package:flutter/material.dart';

class HealthOverviewPage extends StatelessWidget {
  final Map<String, dynamic> pet;
  const HealthOverviewPage({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${pet['name'] ?? 'Pet'} - Health Overview"),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example pet card (can be expanded as needed)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.pets, color: Colors.grey, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet['name'] ?? 'Pet',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${pet['type'] ?? 'Type'} • ${pet['age'] ?? ''} years old",
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'All good',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Next: Vaccination in 2 weeks',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Upcoming Health Events Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Health Events',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(foregroundColor: Colors.teal),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Medication Reminder
            HealthEventCard(
              icon: Icons.favorite,
              iconColor: Colors.red,
              title: 'Medication Reminder',
              titleColor: Colors.red,
              dateLabel: 'Today',
              dateLabelColor: Colors.red,
              description: "Give ${pet['name'] ?? 'your pet'}'s heart medication",
              tags: [
                HealthTag(label: pet['name'] ?? 'Pet', color: Colors.blueGrey),
                HealthTag(
                  label: 'Due now',
                  color: Colors.red,
                  bgColor: Colors.redAccent.withOpacity(0.15),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Vet Appointment
            HealthEventCard(
              icon: Icons.calendar_today,
              iconColor: Colors.blue,
              title: 'Vet Appointment',
              titleColor: Colors.blue,
              dateLabel: 'Tomorrow',
              dateLabelColor: Colors.blue,
              description: "Annual checkup for ${pet['name'] ?? 'your pet'}",
              tags: [
                HealthTag(label: pet['name'] ?? 'Pet', color: Colors.blueGrey),
                HealthTag(
                  label: '2:00 PM',
                  color: Colors.blue,
                  bgColor: Colors.blue.withOpacity(0.15),
                ),
                HealthTag(
                  label: 'Dr. Smith',
                  color: Colors.deepPurple,
                  bgColor: Colors.deepPurple.withOpacity(0.15),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Vaccination
            HealthEventCard(
              icon: Icons.check_circle,
              iconColor: Colors.green,
              title: 'Vaccination',
              titleColor: Colors.green,
              dateLabel: 'Sep 15, 2025',
              dateLabelColor: Colors.grey,
              description: "Annual rabies vaccination for ${pet['name'] ?? 'your pet'}",
              tags: [
                HealthTag(label: pet['name'] ?? 'Pet', color: Colors.blueGrey),
                HealthTag(
                  label: 'Rabies',
                  color: Colors.green,
                  bgColor: Colors.green.withOpacity(0.15),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Vaccination Overdue
            HealthEventCard(
              icon: Icons.warning,
              iconColor: Colors.orange,
              title: 'Vaccination Overdue',
              titleColor: Colors.orange,
              dateLabel: '3 days ago',
              dateLabelColor: Colors.orange,
              description: "FVRCP vaccination for ${pet['name'] ?? 'your pet'}",
              tags: [
                HealthTag(label: pet['name'] ?? 'Pet', color: Colors.blueGrey),
                HealthTag(
                  label: 'FVRCP',
                  color: Colors.orange,
                  bgColor: Colors.orange.withOpacity(0.15),
                ),
                HealthTag(
                  label: 'Overdue',
                  color: Colors.orange,
                  bgColor: Colors.orange.withOpacity(0.15),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
