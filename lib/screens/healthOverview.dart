import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'healthEventCard.dart';
import 'add_health_event_page.dart';

class HealthOverviewPage extends StatefulWidget {
  final Map<String, dynamic> pet;
  const HealthOverviewPage({super.key, required this.pet});

  @override
  State<HealthOverviewPage> createState() => _HealthOverviewPageState();
}

class _HealthOverviewPageState extends State<HealthOverviewPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> reminders = [];
  List<Map<String, dynamic>> healthEvents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    // Fetch reminders
    final reminderResponse = await supabase
        .from('reminders')
        .select()
        .eq('pet_id', widget.pet['id'])
        .order('date', ascending: true);

    // Fetch health events
    final healthResponse = await supabase
        .from('health_events')
        .select()
        .eq('pet_id', widget.pet['id'])
        .order('date', ascending: false);

    setState(() {
      reminders = List<Map<String, dynamic>>.from(reminderResponse);
      healthEvents = List<Map<String, dynamic>>.from(healthResponse);
      isLoading = false;
    });
  }

  Future<void> _navigateToAddRecord() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHealthEventPage(petId: widget.pet['id']),
      ),
    );

    if (result == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;

    return Scaffold(
      appBar: AppBar(
        title: Text("${pet['name'] ?? 'Pet'} - Health Overview"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🐾 Pet Info Card
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
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
                            radius: 28,
                            backgroundColor: Colors.grey[200],
                            child: const Icon(
                              Icons.pets,
                              color: Colors.grey,
                              size: 30,
                            ),
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
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${pet['type'] ?? 'Type'} • ${pet['age'] ?? ''} years old",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 🕒 Reminders Section
                    const Text(
                      'Reminders',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (reminders.isEmpty)
                      const Text(
                        'No reminders yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    for (final reminder in reminders)
                      HealthEventCard(
                        icon: Icons.notifications,
                        iconColor: Colors.orange,
                        title: reminder['title'] ?? 'Reminder',
                        titleColor: Colors.orange,
                        dateLabel: reminder['date'] != null
                            ? reminder['date'].toString().split('T')[0]
                            : '',
                        dateLabelColor: Colors.orange,
                        description:
                            reminder['description'] ??
                            'No description available.',
                        tags: [
                          HealthTag(
                            label: pet['name'] ?? 'Pet',
                            color: Colors.blueGrey,
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),

                    // ❤️ Health Records Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pet Health Records',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Record'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _navigateToAddRecord,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 🩺 Health Records List
                    if (healthEvents.isEmpty)
                      const Text(
                        'No health records found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    for (final event in healthEvents)
                      HealthEventCard(
                        icon: Icons.health_and_safety,
                        iconColor: Colors.green,
                        title: event['title'] ?? 'Health Record',
                        titleColor: Colors.green,
                        dateLabel: event['date'] != null
                            ? event['date'].toString().split('T')[0]
                            : '',
                        dateLabelColor: Colors.grey,
                        description: event['notes'] ?? 'No notes available.',
                        tags: [
                          HealthTag(
                            label: pet['name'] ?? 'Pet',
                            color: Colors.blueGrey,
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
