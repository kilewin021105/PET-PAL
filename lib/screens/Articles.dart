import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const PetPalApp());
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
      home: const ArticlesPage(),
    );
  }
}

class Article {
  final String title;
  final String description;
  final String imageUrl;
  final String altText;
  final List<String> petTypes;
  final String url;

  Article({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.altText,
    required this.petTypes,
    required this.url,
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

  final List<Article> nutritionArticles = [
    Article(
      title: 'Balanced Nutrition for Dogs',
      description:
          'Understand the essential nutrients your canine companion needs, from proteins to vitamins, to ensure a healthy and active life.',
      imageUrl: 'https://images.unsplash.com/photo-1589941013453-ec89f33b5e95?w=400&h=250&fit=crop&crop=center',
      altText: 'Healthy dog food in a bowl',
      petTypes: ['dog'],
      url: 'https://www.akc.org/expert-advice/nutrition/dog-nutrition-tips/',
    ),
    Article(
      title: 'Cat Nutrition Essentials',
      description:
          'Explore what makes a perfect meal for your feline friend, including the role of taurine and hydration tips.',
      imageUrl: 'https://images.unsplash.com/photo-1548247416-ec66f4900b2e?w=400&h=250&fit=crop&crop=center',
      altText: 'Fresh fish and greens in a cat bowl',
      petTypes: ['cat'],
      url: 'https://www.aspca.org/pet-care/cat-care/cat-nutrition-tips',
    ),
    Article(
      title: 'Feeding Your Pet Bird',
      description:
          'From seed mixes to fresh produce, learn how to provide optimal nutrition for vibrant plumage and energy.',
      imageUrl: 'https://images.unsplash.com/photo-1452570053594-1b985d6ea890?w=400&h=250&fit=crop&crop=center',
      altText: 'Bird food assortment',
      petTypes: ['bird'],
      url: 'https://www.petmd.com/bird/nutrition/evr_bd_feeding_your_pet_bird',
    ),
  ];

  final List<Article> groomingArticles = [
    Article(
      title: '5-Minute Dog Brush Routine',
      description:
          'A speedy guide to removing dirt, mats, and loose fur to maintain your dog\'s coat in top condition.',
      imageUrl: 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=400&h=250&fit=crop&crop=center',
      altText: 'Brushing dog coat',
      petTypes: ['dog'],
      url: 'https://www.petmd.com/dog/grooming/how-brush-your-dog',
    ),
    Article(
      title: 'Express Cat Nail Trim',
      description:
          'Tips for quick and safe nail trimming to prevent scratches and promote good paw health.',
      imageUrl: 'https://images.unsplash.com/photo-1574144611937-0df059b5ef3e?w=400&h=250&fit=crop&crop=center',
      altText: 'Trimming cat nails',
      petTypes: ['cat'],
      url: 'https://www.aspca.org/pet-care/cat-care/cat-grooming-tips',
    ),
    Article(
      title: 'Bird Wing Clipping Simplified',
      description:
          'Step-by-step for trimming feathers safely to keep your bird grounded while maintaining flight muscles.',
      imageUrl: 'https://images.unsplash.com/photo-1444464666168-49d633b86797?w=400&h=250&fit=crop&crop=center',
      altText: 'Bird grooming',
      petTypes: ['bird'],
      url: 'https://www.petmd.com/bird/care/evr_bd_wing_clipping',
    ),
  ];

  final List<Article> recommendedArticles = [
    Article(
      title: 'Dog Exercise Routines',
      description: 'Tailored workouts to keep your canine active and happy.',
      imageUrl: 'https://images.unsplash.com/photo-1551717743-49959800b1f6?w=400&h=250&fit=crop&crop=center',
      altText: 'Dog fetching ball',
      petTypes: ['dog'],
      url: 'https://www.akc.org/expert-advice/health/puppy-exercise-too-much-too-little/',
    ),
    Article(
      title: 'Dog Health Checkups',
      description: 'What to expect at vet visits for optimal health.',
      imageUrl: 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=400&h=250&fit=crop&crop=center',
      altText: 'Vet examining dog',
      petTypes: ['dog'],
      url: 'https://www.petmd.com/dog/wellness/evr_dg_routine_veterinary_care',
    ),
    Article(
      title: 'Cat Enrichment Ideas',
      description: 'Ways to stimulate your feline\'s mind and prevent boredom.',
      imageUrl: 'https://images.unsplash.com/photo-1573865526739-10659fec78a5?w=400&h=250&fit=crop&crop=center',
      altText: 'Cat with toys',
      petTypes: ['cat'],
      url: 'https://www.aspca.org/pet-care/cat-care/enriching-your-cats-life',
    ),
    Article(
      title: 'Common Cat Behaviors',
      description: 'Decoding purring, scratching, and other feline actions.',
      imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=250&fit=crop&crop=center',
      altText: 'Siamese cat by window',
      petTypes: ['cat'],
      url: 'https://www.petmd.com/cat/behavior/evr_ct_why_do_cats_purr',
    ),
    Article(
      title: 'Bird Vocalization Training',
      description: 'Teaching your bird to mimic and communicate.',
      imageUrl: 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=400&h=250&fit=crop&crop=center',
      altText: 'Parrot talking',
      petTypes: ['bird'],
      url: 'https://www.petmd.com/bird/behavior/evr_bd_teaching_your_bird_to_talk',
    ),
    Article(
      title: 'Bird Cage Essentials',
      description: 'Must-have setup for a comfortable bird habitat.',
      imageUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=400&h=250&fit=crop&crop=center',
      altText: 'Bird cage setup',
      petTypes: ['bird'],
      url: 'https://www.petmd.com/bird/care/evr_bd_bird_cage_setup',
    ),
    Article(
      title: 'General Exotic Pet Care',
      description:
          'Basic tips for rabbits, hamsters, and other non-traditional pets.',
      imageUrl: 'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=400&h=250&fit=crop&crop=center',
      altText: 'Exotic pets care',
      petTypes: ['other'],
      url: 'https://www.aspca.org/pet-care/small-pet-care',
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
    if (selectedPetType == null) return [];
    return recommendedArticles
        .where((article) => article.petTypes.contains(selectedPetType))
        .toList();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      // Handle error - show a snackbar or dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open article: $e')),
        );
      }
    }
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(article.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _launchURL(article.url),
                  child: const Text('Read More'),
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
            'Learn how to feed your pet properly with our comprehensive guides covering balanced diets, portion control, and specific nutritional needs.',
            style: TextStyle(fontSize: 16),
          ),
        ),
        ...nutritionArticles.map(buildArticleCard),
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
            'Efficient care routines to keep your pet clean and healthy without spending hours. Perfect for on-the-go lifestyles.',
            style: TextStyle(fontSize: 16),
          ),
        ),
        ...groomingArticles.map(buildArticleCard),
      ],
    );
  }

  Widget buildRecommendationsTab() {
    final filteredArticles = getFilteredRecommendedArticles();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Choose Your Pet Type',
              border: OutlineInputBorder(),
            ),
            value: selectedPetType,
            items: const [
              DropdownMenuItem(value: null, child: Text('-- Select Pet Type --')),
              DropdownMenuItem(value: 'dog', child: Text('Dog')),
              DropdownMenuItem(value: 'cat', child: Text('Cat')),
              DropdownMenuItem(value: 'bird', child: Text('Bird')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (value) {
              setState(() {
                selectedPetType = value;
              });
            },
          ),
        ),
        Expanded(
          child: filteredArticles.isEmpty
              ? Center(
                  child: Text(
                    selectedPetType == null
                        ? 'Please select a pet type to see recommendations.'
                        : 'No articles found for the selected pet type.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView(
                  children: filteredArticles.map(buildArticleCard).toList(),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PetPal Articles'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
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
