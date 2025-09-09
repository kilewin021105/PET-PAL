import 'package:flutter/material.dart';

void main() {
  runApp(PetPalApp());
}

class PetPalApp extends StatelessWidget {
  const PetPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetPal Articles',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ArticlesPage(),
    );
  }
}

class Article {
  final String title;
  final String description;
  final String imageUrl;
  final String altText;
  final List<String> petTypes; // e.g. ['dog'], ['cat'], ['bird'], or empty for general

  Article({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.altText,
    required this.petTypes,
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

  // Sample articles data
  final List<Article> nutritionArticles = [
    Article(
      title: 'Balanced Nutrition for Dogs',
      description:
          'Understand the essential nutrients your canine companion needs, from proteins to vitamins, to ensure a healthy and active life.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Colorful bowl of healthy dry kibble mixed with fresh vegetables and cooked meat for dogs, placed on a white ceramic bowl',
      petTypes: ['dog'],
    ),
    Article(
      title: 'Cat Nutrition Essentials',
      description:
          'Explore what makes a perfect meal for your feline friend, including the role of taurine and hydration tips.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Fresh fish fillets, rice, and mixed greens arranged in a cat food bowl on a sleek countertop',
      petTypes: ['cat'],
    ),
    Article(
      title: 'Feeding Your Pet Bird',
      description:
          'From seed mixes to fresh produce, learn how to provide optimal nutrition for vibrant plumage and energy.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Assortment of seeds, fruits, and nutrients laid out in a colorful pet bird feeder tray',
      petTypes: ['bird'],
    ),
  ];

  final List<Article> groomingArticles = [
    Article(
      title: '5-Minute Dog Brush Routine',
      description:
          'A speedy guide to removing dirt, mats, and loose fur to maintain your dog\'s coat in top condition.',
      imageUrl: '',
      altText: '',
      petTypes: ['dog'],
    ),
    Article(
      title: 'Express Cat Nail Trim',
      description:
          'Tips for quick and safe nail trimming to prevent scratches and promote good paw health.',
      imageUrl: '',
      altText: '',
      petTypes: ['cat'],
    ),
    Article(
      title: 'Bird Wing Clipping Simplified',
      description:
          'Step-by-step for trimming feathers safely to keep your bird grounded while maintaining flight muscles.',
      imageUrl: '',
      altText: '',
      petTypes: ['bird'],
    ),
  ];

  final List<Article> recommendedArticles = [
    // Dog
    Article(
      title: 'Dog Exercise Routines',
      description: 'Tailored workouts to keep your canine active and happy.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Playful golden retriever dog fetching a ball in a sunny park with green grass',
      petTypes: ['dog'],
    ),
    Article(
      title: 'Dog Health Checkups',
      description: 'What to expect at vet visits for optimal health.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Veterinarian holding a stethoscope to a labrador dog\'s chest in a clinical setting',
      petTypes: ['dog'],
    ),
    // Cat
    Article(
      title: 'Cat Enrichment Ideas',
      description:
          'Ways to stimulate your feline\'s mind and prevent boredom.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Curious ginger cat exploring indoor cat scratching post and toys',
      petTypes: ['cat'],
    ),
    Article(
      title: 'Common Cat Behaviors',
      description:
          'Decoding purring, scratching, and other feline actions.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Elegant siamese cat sitting on a window sill overlooking a city street',
      petTypes: ['cat'],
    ),
    // Bird
    Article(
      title: 'Bird Vocalization Training',
      description: 'Teaching your bird to mimic and communicate.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Vibrant parrot perched on a branch with tropical leaves in a bright indoor aviary',
      petTypes: ['bird'],
    ),
    Article(
      title: 'Bird Cage Essentials',
      description: 'Must-have setup for a comfortable bird habitat.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Assorted bird cages with different types of seed, perches, and water dishes',
      petTypes: ['bird'],
    ),
    // Other
    Article(
      title: 'General Exotic Pet Care',
      description:
          'Basic tips for rabbits, hamsters, and other non-traditional pets.',
      imageUrl: 'https://placehold.co/400x250',
      altText:
          'Collage of various exotic pets like hamsters, rabbits, and fish in pet-friendly containers',
      petTypes: ['other'],
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

  Widget buildArticleCard(Article article) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                article.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: Text(
                      article.altText,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text(article.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Placeholder for "Read More" action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Read more tapped for "${article.title}"')),
                    );
                  },
                  child: Text('Read More'),
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
      padding: EdgeInsets.only(bottom: 16),
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'Learn how to feed your pet properly with our comprehensive guides covering balanced diets, portion control, and specific nutritional needs.',
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
        ),
        ...nutritionArticles.map(buildArticleCard),
      ],
    );
  }

  Widget buildGroomingTab() {
    return ListView(
      padding: EdgeInsets.only(bottom: 16),
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'Efficient care routines to keep your pet clean and healthy without spending hours. Perfect for on-the-go lifestyles.',
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
        ),
        ...groomingArticles.map(buildArticleCard),
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
            decoration: InputDecoration(
              labelText: 'Choose Your Pet Type',
              border: OutlineInputBorder(),
            ),
            initialValue: selectedPetType,
            items: [
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
          SizedBox(height: 16),
          if (selectedPetType == null)
            Expanded(
              child: Center(
                child: Text(
                  'Please select a pet type to see recommendations.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (filteredArticles.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No articles found for the selected pet type.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                children: filteredArticles.map(buildArticleCard).toList(),
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
        title: Text('PetPal Articles'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Nutrition'),
            Tab(text: 'Grooming'),
            Tab(text: 'Recommendations'),
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