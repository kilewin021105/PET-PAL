import 'package:flutter/material.dart';

class Article {
  final String title;
  final String description; // short summary
  final String imageUrl;
  final String altText;
  final List<String> petTypes; // e.g. ['dog'], ['cat'], ['bird'], or empty for general
  final List<String> tips; // detailed pet care tips revealed inline

  Article({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.altText,
    required this.petTypes,
    required this.tips,
  });
}

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Track expanded cards using a stable key per section-index
  final Set<String> _expanded = {};

  // Pet care tips data
  final List<Article> nutritionArticles = [
    Article(
      title: 'Balanced Nutrition for Dogs',
      description:
          'Essential nutrients for your dog: proteins, fats, carbs, vitamins, and minerals.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Colorful bowl of healthy dry kibble mixed with fresh vegetables and cooked meat for dogs, placed on a white ceramic bowl',
      petTypes: ['dog'],
      tips: [
        'Choose complete and balanced food that meets AAFCO standards for your dog\'s life stage.',
        'Portion by weight, age, and activity. Use a measuring cup; avoid free-feeding if weight is a concern.',
        'Transition foods over 7–10 days to prevent stomach upset (mix increasing amounts of the new food).',
        'Fresh water at all times. Avoid toxic foods: grapes/raisins, onions/garlic, chocolate, xylitol.',
      ],
    ),
    Article(
      title: 'Cat Nutrition Essentials',
      description:
          'What makes an ideal feline meal and how to keep your cat hydrated and healthy.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Fresh fish fillets, rice, and mixed greens arranged in a cat food bowl on a sleek countertop',
      petTypes: ['cat'],
      tips: [
        'Taurine is essential for cats—feed a complete, balanced cat diet (not dog food).',
        'High-moisture foods (wet food) support urinary health; encourage drinking with multiple water bowls/fountains.',
        'Feed small frequent meals; monitor body condition score monthly.',
        'Avoid cow\'s milk, raw bones, and highly seasoned human foods.',
      ],
    ),
    Article(
      title: 'Feeding Your Pet Bird',
      description:
          'Pellets, fresh veggies, and safe fruits form the core of a healthy avian diet.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Assortment of seeds, fruits, and nutrients laid out in a colorful pet bird feeder tray',
      petTypes: ['bird'],
      tips: [
        'Aim for ~60–70% pellets, 20–30% vegetables/greens, and ~5–10% fruit as treats.',
        'Avoid avocado, chocolate, caffeine, and alcohol—they are toxic to birds.',
        'Change water and clean bowls daily; remove fresh foods after 2 hours to prevent spoilage.',
        'Offer foraging toys and varied textures to encourage natural feeding behavior.',
      ],
    ),
    // More nutrition tips
    Article(
      title: 'Healthy Treats & Portion Control',
      description: 'Keep treats under 10% of daily calories for all pets.',
      imageUrl: 'https://placehold.co/400x250',
      altText: 'Measuring scoop with kibble and small healthy pet treats',
      petTypes: ['dog', 'cat', 'bird', 'other'],
      tips: [
        'Use a measuring cup or scale for precise feeding; adjust with activity level and weight goals.',
        'Choose single-ingredient treats (freeze-dried meat/veg) and avoid high-sugar snacks.',
        'For birds, use training treats sparingly to maintain balanced pellet intake.',
      ],
    ),
    Article(
      title: 'Senior Pet Nutrition',
      description: 'Support aging pets with joint, dental, and kidney-friendly diets.',
      imageUrl: 'https://placehold.co/400x250',
      altText: 'Senior dog and cat resting comfortably indoors',
      petTypes: ['dog', 'cat'],
      tips: [
        'Consider diets with joint support (glucosamine/chondroitin) and controlled calories to prevent weight gain.',
        'For cats, prioritize kidney-friendly options with appropriate phosphorus levels—consult your vet.',
        'Schedule routine wellness checks and adjust diets based on bloodwork and body condition.',
      ],
    ),
  ];

  final List<Article> groomingArticles = [
    Article(
      title: '5-Minute Dog Brush Routine',
      description:
          'Quick steps to reduce shedding and keep the coat clean and comfortable.',
      imageUrl: '',
      altText: '',
      petTypes: ['dog'],
      tips: [
        'Pick the right brush (slicker for long coats, bristle/rubber for short coats).',
        'Brush along hair growth; use short sessions to avoid skin irritation.',
        'De-shed weekly during coat blow; detangle mats gently or seek groomer help.',
        'Reward calm behavior to build a positive association with grooming.',
      ],
    ),
    Article(
      title: 'Express Cat Nail Trim',
      description:
          'Keep nails short to prevent scratches and support paw health.',
      imageUrl: '',
      altText: '',
      petTypes: ['cat'],
      tips: [
        'Use proper cat nail clippers; press the pad to extend the claw.',
        'Identify the pink quick and trim only the clear tip in small increments.',
        'Provide sturdy scratching posts to reduce overgrowth and redirect scratching.',
        'Keep styptic powder nearby; if anxious, trim one or two claws per session.',
      ],
    ),
    Article(
      title: 'Bird Wing & Nail Care (Safety First)',
      description:
          'Trimming should be done by trained owners or professionals to avoid injury.',
      imageUrl: '',
      altText: '',
      petTypes: ['bird'],
      tips: [
        'Consult an avian vet for guidance before attempting any wing or nail trims.',
        'Avoid cutting blood feathers; use proper restraint and bright lighting.',
        'Prioritize environmental safety (closed doors/windows) when practicing flight recall.',
      ],
    ),
    // More grooming tips
    Article(
      title: 'Bathing Basics for Dogs',
      description: 'How often and how to bathe safely without drying the skin.',
      imageUrl: 'https://placehold.co/400x250',
      altText: 'Dog in a bathtub with pet-safe shampoo',
      petTypes: ['dog'],
      tips: [
        'Use lukewarm water and pet-safe shampoo; avoid human products.',
        'Brush before bathing to remove mats; rinse thoroughly to prevent residue.',
        'Bath frequency depends on coat/skin—typically every 4–8 weeks or as advised by your vet.',
      ],
    ),
    Article(
      title: 'Dental Care for Cats & Dogs',
      description: 'Daily dental hygiene reduces plaque and prevents periodontal disease.',
      imageUrl: 'https://placehold.co/400x250',
      altText: 'Pet toothbrush and dental treats',
      petTypes: ['dog', 'cat'],
      tips: [
        'Brush teeth with pet toothpaste (never use human toothpaste).',
        'Incorporate dental treats and chews approved by the VOHC where available.',
        'Schedule professional cleanings as recommended by your veterinarian.',
      ],
    ),
  ];

  final List<Article> recommendedArticles = [
    // Dog
    Article(
      title: 'Dog Exercise Routines',
      description: 'Workouts to keep your dog fit and mentally engaged.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Playful golden retriever dog fetching a ball in a sunny park with green grass',
      petTypes: ['dog'],
      tips: [
        'Aim for 30–60 minutes of daily activity; adjust based on breed and age.',
        'Mix walks with sniffaris, fetch, puzzle toys, and basic obedience drills.',
        'Watch for overheating; bring water and avoid hot pavements.',
      ],
    ),
    Article(
      title: 'Dog Health Checkups',
      description: 'What to expect during routine vet visits.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Veterinarian holding a stethoscope to a labrador dog\'s chest in a clinical setting',
      petTypes: ['dog'],
      tips: [
        'Annual exams (biannual for seniors) to screen for dental, joint, and organ issues.',
        'Stay current on vaccines, parasite prevention, and heartworm testing.',
        'Track weight trends and discuss nutrition with your vet.',
      ],
    ),
    // Cat
    Article(
      title: 'Cat Enrichment Ideas',
      description: 'Keep indoor cats active and happy with engaging play.',
      imageUrl: 'https://placehold.co/400x250',
      altText: 'Curious ginger cat exploring indoor cat scratching post and toys',
      petTypes: ['cat'],
      tips: [
        'Daily interactive play with wand toys; rotate toys to prevent boredom.',
        'Provide vertical space (cat trees, shelves) and safe window perches.',
        'Use food puzzles for mental stimulation and weight control.',
      ],
    ),
    Article(
      title: 'Common Cat Behaviors',
      description: 'Understanding purring, scratching, kneading, and more.',
      imageUrl: 'https://placehold.co/400x250',
      altText: 'Elegant siamese cat sitting on a window sill overlooking a city street',
      petTypes: ['cat'],
      tips: [
        'Scratching marks territory and maintains nails—offer multiple posts in key areas.',
        'Slow blinks and soft purring usually indicate contentment; observe context for accuracy.',
        'Address litter box issues with extra boxes (n+1 rule), cleanliness, and stress reduction.',
      ],
    ),
    // Bird
    Article(
      title: 'Bird Vocalization Training',
      description: 'Teach mimicry and build a communication routine.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Vibrant parrot perched on a branch with tropical leaves in a bright indoor aviary',
      petTypes: ['bird'],
      tips: [
        'Practice short, consistent sessions; reward desired sounds immediately.',
        'Model words/whistles clearly; avoid reinforcing screams with attention.',
        'Pair training with hand-feeding to strengthen the bond and focus.',
      ],
    ),
    Article(
      title: 'Bird Cage Essentials',
      description: 'Create a comfortable, enriching habitat setup.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Assorted bird cages with different types of seed, perches, and water dishes',
      petTypes: ['bird'],
      tips: [
        'Use varied perch sizes/materials to prevent pressure sores (avoid only dowel perches).',
        'Place food and water away from perches to reduce contamination; clean daily.',
        'Provide safe chew toys and rotate enrichment items weekly.',
      ],
    ),
    // Other
    Article(
      title: 'General Exotic Pet Care',
      description: 'Quick-start basics for rabbits, hamsters, and more.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Collage of various exotic pets like hamsters, rabbits, and fish in pet-friendly containers',
      petTypes: ['other'],
      tips: [
        'Research species-specific housing, temperature, and humidity needs.',
        'Provide species-appropriate hides, chew items, and enrichment for stress reduction.',
        'Establish with an exotics-savvy veterinarian for routine care guidance.',
      ],
    ),
  ];

  String? selectedPetType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    selectedPetType = null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Article> getFilteredRecommendedArticles() {
    if (selectedPetType == null || selectedPetType == '') {
      return [];
    }
    return recommendedArticles
        .where((article) => article.petTypes.contains(selectedPetType))
        .toList();
  }

  Widget _buildTipsList(Article article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 20),
        const Text(
          'Tips',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...article.tips.map(
          (t) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, size: 18, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildArticleCard(Article article, String section, int index) {
    final cardKey = '$section-$index';
    final isExpanded = _expanded.contains(cardKey);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                    Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  article.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                if (isExpanded) _buildTipsList(article),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        if (isExpanded) {
                          _expanded.remove(cardKey);
                        } else {
                          _expanded.add(cardKey);
                        }
                      });
                    },
                    icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                    label: Text(isExpanded ? 'Show less' : 'Read more'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNutritionTab() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Nutrition tips to help you feed your pet properly: balanced diets, portion control, hydration, and life-stage needs.',
            style: TextStyle(fontSize: 16),
          ),
        ),
        ...nutritionArticles.asMap().entries.map(
              (e) => buildArticleCard(e.value, 'nutrition', e.key),
            ),
      ],
    );
  }

  Widget buildGroomingTab() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Quick, effective grooming tips to keep your pet clean, comfortable, and healthy.',
            style: TextStyle(fontSize: 16),
          ),
        ),
        ...groomingArticles.asMap().entries.map(
              (e) => buildArticleCard(e.value, 'grooming', e.key),
            ),
      ],
    );
  }

  Widget buildRecommendationsTab() {
    final filteredArticles = getFilteredRecommendedArticles();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Choose Your Pet Type',
              border: OutlineInputBorder(),
            ),
            initialValue: selectedPetType,
            items: const [
              DropdownMenuItem(value: '', child: Text('-- Select Pet Type --')),
              DropdownMenuItem(value: 'dog', child: Text('Dog')),
              DropdownMenuItem(value: 'cat', child: Text('Cat')),
              DropdownMenuItem(value: 'bird', child: Text('Bird')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (value) {
              setState(() {
                selectedPetType = value == '' ? null : value;
              });
            },
          ),
          const SizedBox(height: 16),
          if (selectedPetType == null)
            Expanded(
              child: Center(
                child: Text(
                  'Please select a pet type to see recommended tips.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (filteredArticles.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No tips found for the selected pet type.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                children: filteredArticles
                    .asMap()
                    .entries
                    .map((e) => buildArticleCard(e.value, 'recommendations', e.key))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Care Tips'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Nutrition Tips'),
            Tab(text: 'Grooming Tips'),
            Tab(text: 'Recommended Tips'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildNutritionTab(),
          buildGroomingTab(),
          buildRecommendationsTab(),
        ],
      ),
    );
  }
}
