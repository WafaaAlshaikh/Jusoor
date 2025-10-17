// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class InitialScreeningScreen extends StatefulWidget {
  const InitialScreeningScreen({super.key});

  @override
  State<InitialScreeningScreen> createState() => _InitialScreeningScreenState();
}

class _InitialScreeningScreenState extends State<InitialScreeningScreen> {
  // إجابات المستخدم
  final Map<String, int> _answers = {
    'language': 0,
    'social': 0,
    'motor': 0,
    'academic': 0,
  };

  bool _submitted = false;
  String _result = '';

  // دالة حساب النتيجة النهائية
  void _calculateResult() {
    int total = _answers.values.reduce((a, b) => a + b);
    String classification;

    if (total <= 4) {
      classification = '🟢 طبيعي - لا توجد مؤشرات تدعو للقلق';
    } else if (total <= 8) {
      classification = '🟡 يحتاج متابعة - يُفضّل مراقبة التقدّم';
    } else {
      classification = '🔴 يحتاج تدخل - يُنصح بمراجعة أخصائي';
    }

    setState(() {
      _result = classification;
      _submitted = true;
    });
  }

  // عنصر تقييم فردي (سؤال)
  Widget buildQuestion({
    required String title,
    required String keyName,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: Text('لا'),
                  selected: _answers[keyName] == 0,
                  onSelected: (selected) {
                    setState(() {
                      _answers[keyName] = 0;
                    });
                  },
                ),
                ChoiceChip(
                  label: Text('أحيانًا'),
                  selected: _answers[keyName] == 1,
                  onSelected: (selected) {
                    setState(() {
                      _answers[keyName] = 1;
                    });
                  },
                ),
                ChoiceChip(
                  label: Text('دائمًا'),
                  selected: _answers[keyName] == 2,
                  onSelected: (selected) {
                    setState(() {
                      _answers[keyName] = 2;
                    });
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Initial Screening'),
        backgroundColor: ParentAppColors.primaryColor,
      ),
      body: _submitted
          ? _buildResultView()
          : SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            Text(
              '🧠 تقييم مبدئي للطفل',
              style:
              TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'أجب عن الأسئلة التالية لتحديد احتياجات الطفل الأولية:',
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // الأسئلة
            buildQuestion(
                title:
                'هل الطفل يتحدث جمل واضحة ويتفاعل لغويًا؟',
                keyName: 'language'),
            buildQuestion(
                title:
                'هل الطفل يتفاعل اجتماعيًا مع الآخرين؟',
                keyName: 'social'),
            buildQuestion(
                title:
                'هل يستطيع الطفل أداء الحركات الأساسية (مثل الجري أو الإمساك بالأشياء الصغيرة)؟',
                keyName: 'motor'),
            buildQuestion(
                title:
                'هل يواجه الطفل صعوبة في الانتباه أو التعلم؟',
                keyName: 'academic'),

            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ParentAppColors.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              onPressed: _calculateResult,
              child: Text('عرض النتيجة',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // صفحة النتيجة
  Widget _buildResultView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                color: ParentAppColors.primaryColor, size: 80),
            SizedBox(height: 20),
            Text('نتيجة الفحص المبدئي:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text(
              _result,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _submitted = false;
                  _result = '';
                  _answers.updateAll((key, value) => 0);
                });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: ParentAppColors.primaryColor),
              child: Text('إعادة التقييم'),
            ),
          ],
        ),
      ),
    );
  }
}
