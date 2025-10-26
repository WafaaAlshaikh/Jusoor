// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class EducationalResourcesScreen extends StatefulWidget {
  const EducationalResourcesScreen({super.key});

  @override
  State<EducationalResourcesScreen> createState() => _EducationalResourcesScreenState();
}

class _EducationalResourcesScreenState extends State<EducationalResourcesScreen> {
  List<dynamic> resources = [];
  List<String> favoriteLinks = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedType = 'All';
  List<String> typeOptions = ['All', 'Article', 'Video', 'PDF'];

  // Additional filters
  String selectedAge = 'All Ages';
  String selectedSkill = 'All Skills';
  final List<String> ages = ['All Ages', '3-5', '6-9', '10-13', '14+'];
  final List<String> skills = ['All Skills', 'Speech', 'Behavior', 'Focus'];

  // Chat AI
  List<Map<String, String>> messages = [];
  final TextEditingController chatController = TextEditingController();
  bool isSending = false;
  bool isChatOpen = false;

  List<String> weeklyPlan = [];
  Map<String, String> personalNotes = {};

  @override
  void initState() {
    super.initState();
    fetchResources();
    loadFavorites();
    loadWeeklyPlan();
    loadNotes();
  }

  Future<void> fetchResources() async {
    try {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await ApiService.getParentResources(token);
      setState(() {
        resources = response;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching resources: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteLinks = prefs.getStringList('favorites') ?? [];
    });
  }

  Future<void> toggleFavorite(String link) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteLinks.contains(link)) {
        favoriteLinks.remove(link);
      } else {
        favoriteLinks.add(link);
      }
    });
    await prefs.setStringList('favorites', favoriteLinks);
  }

  Future<void> loadWeeklyPlan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      weeklyPlan = prefs.getStringList('weekly_plan') ?? [];
    });
  }

  Future<void> addToWeeklyPlan(String link) async {
    final prefs = await SharedPreferences.getInstance();
    if (!weeklyPlan.contains(link)) {
      weeklyPlan.add(link);
      await prefs.setStringList('weekly_plan', weeklyPlan);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to weekly plan')));
    }
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesStr = prefs.getString('notes') ?? '{}';
    setState(() {
      personalNotes = Map<String, String>.from(parseNotes(notesStr));
    });
  }

  Map<String, String> parseNotes(String str) {
    final Map<String, String> map = {};
    str.replaceAll(RegExp(r"[{}]"), '').split(',').forEach((element) {
      if (element.trim().isEmpty) return;
      final split = element.split(':');
      if (split.length == 2) map[split[0].trim()] = split[1].trim();
    });
    return map;
  }

  Future<void> saveNote(String link, String note) async {
    final prefs = await SharedPreferences.getInstance();
    personalNotes[link] = note;
    await prefs.setString('notes', personalNotes.toString());
  }

  void sendMessage() async {
    final text = chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'text': text});
      chatController.clear();
      isSending = true;
    });

    // Mock AI Response
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      messages.add({'role': 'ai', 'text': '🤖 AI Response: "$text"'});
      isSending = false;
    });
  }

  bool isNewResource(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    return diff <= 7;
  }

  bool isTrending(int views) => views >= 100;

  List<dynamic> getRecommended(String type) {
    return resources
        .where((r) => r['type'].toString().toLowerCase() == type.toLowerCase())
        .take(3)
        .toList();
  }

  Widget _buildSideSection({required String title, required IconData icon, required List items}) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal),
                const SizedBox(width: 6),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (ctx, idx) {
                  final item = items[idx];
                  return InkWell(
                    onTap: () async {
                      if (item['link'] != null) {
                        await launchUrl(Uri.parse(item['link']));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        item['title'],
                        style: TextStyle(color: Colors.teal[800], fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredResources = resources.where((r) {
      final matchesType = selectedType == 'All'
          ? true
          : r['type'].toString().toLowerCase() == selectedType.toLowerCase();
      final matchesSearch = r['title']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase()) ||
          r['description']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
      final matchesAge = selectedAge == 'All Ages' ? true : r['age_group'] == selectedAge;
      final matchesSkill = selectedSkill == 'All Skills' ? true : r['skill_type'] == selectedSkill;
      return matchesType && matchesSearch && matchesAge && matchesSkill;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('🎓 Educational Resources'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 2,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Favorite Resources
            if (favoriteLinks.isNotEmpty) ...[
              const Text("⭐ Favorites", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: favoriteLinks.map((link) {
                    final resource = resources.firstWhere((r) => r['link'] == link, orElse: () => null);
                    if (resource == null) return SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () => launchUrl(Uri.parse(resource['link'])),
                        child: Container(
                          width: 180,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: Offset(0,3))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(resource['title'], style: TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                              SizedBox(height: 4),
                              Text(resource['description'], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Search Field
            TextField(
              decoration: InputDecoration(
                hintText: 'Search resources...',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
            const SizedBox(height: 10),

            // Type Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: typeOptions.map((type) {
                  final isSelected = selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (_) => setState(() => selectedType = type),
                      selectedColor: Colors.teal,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor: Colors.white,
                      elevation: 3,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),

            // Additional filters
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      labelText: 'Child Age Group',
                    ),
                    value: selectedAge,
                    items: ages.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                    onChanged: (v) => setState(() => selectedAge = v ?? 'All Ages'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      labelText: 'Skill Type',
                    ),
                    value: selectedSkill,
                    items: skills.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => selectedSkill = v ?? 'All Skills'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Resource Cards
            ...filteredResources.map((r) {
              final isFav = favoriteLinks.contains(r['link']);
              final dateAdded = DateTime.tryParse(r['date'] ?? '') ?? DateTime.now();
              final trending = isTrending(r['views'] ?? 0);
              final newResource = isNewResource(dateAdded);

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () async {
                    await launchUrl(Uri.parse(r['link']));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              r['type'] == 'video'
                                  ? Icons.video_library
                                  : r['type'] == 'pdf'
                                  ? Icons.picture_as_pdf
                                  : Icons.article,
                              color: Colors.teal,
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(r['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            if (newResource) Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)), child: Text('🆕 New', style: TextStyle(fontSize: 12))),
                            if (trending) Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(8)), child: Text('🔥 Trending', style: TextStyle(fontSize: 12))),
                            IconButton(
                              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.grey),
                              onPressed: () => toggleFavorite(r['link']),
                            ),
                            IconButton(
                              icon: Icon(Icons.download, color: Colors.teal),
                              onPressed: () => launchUrl(Uri.parse(r['link'])),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(r['description'], style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 10),

            // Side Sections
            Container(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _buildSideSection(
                    title: '⭐ Recommended',
                    icon: Icons.star,
                    items: resources.take(3).toList(),
                  ),
                  const SizedBox(width: 10),
                  _buildSideSection(
                    title: '🧩 Activities',
                    icon: Icons.extension,
                    items: [
                      {'title': 'Focus Game', 'link': 'https://example.com/activity1'},
                      {'title': 'Speech Activity', 'link': 'https://example.com/activity2'},
                      {'title': 'Behavior Exercise', 'link': 'https://example.com/activity3'},
                    ],
                  ),
                  const SizedBox(width: 10),
                  _buildSideSection(
                    title: '📰 News & Tips',
                    icon: Icons.newspaper,
                    items: [
                      {'title': 'Special Education Article', 'link': 'https://example.com/news1'},
                      {'title': 'Expert Tip', 'link': 'https://example.com/tip1'},
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60), // space for chat
          ],
        ),
      ),

      // Floating Chat Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => setState(() => isChatOpen = !isChatOpen),
        child: Icon(isChatOpen ? Icons.close : Icons.chat_bubble),
      ),

      // Chat Bottom Sheet
      bottomSheet: isChatOpen
          ? Container(
        height: 420,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text('🤖 Ask AI Assistant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: messages.length,
                itemBuilder: (ctx, i) {
                  final msg = messages[i];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.teal : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg['text']!, style: TextStyle(color: isUser ? Colors.white : Colors.black87)),
                    ),
                  );
                },
              ),
            ),
            Wrap(
              spacing: 8,
              children: [
                "Hyperactivity tips",
                "Home speech exercises",
                "How to handle autistic child",
              ].map((q) => ActionChip(
                label: Text(q),
                onPressed: () {
                  chatController.text = q;
                  sendMessage();
                },
                backgroundColor: Colors.teal[50],
              )).toList(),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatController,
                    decoration: const InputDecoration(
                      hintText: 'Type your question...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: isSending ? const CircularProgressIndicator() : const Icon(Icons.send, color: Colors.teal),
                  onPressed: isSending ? null : sendMessage,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      )
          : null,
    );
  }
}
