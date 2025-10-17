// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';

class EducationalResourcesScreen extends StatelessWidget {
  const EducationalResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> resources = [
      {
        'title': 'Understanding Autism Spectrum Disorder',
        'description': 'A guide for parents to understand autism and how to support children with ASD.',
        'link': 'https://www.autismspeaks.org/what-autism'
      },
      {
        'title': 'Speech Therapy Exercises at Home',
        'description': 'Simple activities to improve your child’s speech and language development.',
        'link': 'https://www.speechandlanguagekids.com/'
      },
      {
        'title': 'Parenting Children with Special Needs',
        'description': 'Tips and strategies for creating a supportive home environment.',
        'link': 'https://www.verywellfamily.com/parenting-a-child-with-special-needs-4157233'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Educational Resources'),
        backgroundColor: ParentAppColors.primaryColor,
      ),
      body: ListView.builder(
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final resource = resources[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(resource['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(resource['description']!),
              trailing: Icon(Icons.open_in_new, color: ParentAppColors.primaryColor),
              onTap: () {
                // تفتح الرابط في المتصفح الخارجي
                _openLink(context, resource['link']!);
              },
            ),
          );
        },
      ),
    );
  }


  void _openLink(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the link')),
      );
    }
  }

}
