import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:healthsnapai_application_1/l10n/app_strings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

// ════════════════════════════════════════════════
// 🔑 مجاني 100% - Gemini API من Google
// احصل على مفتاحك المجاني من:
// https://aistudio.google.com/app/apikey
const String _kApiKey =
    'AIzaSyBPxW1nNhvQ1E-VEH4xKUVL2dgj5pSLvAI'; // ← غيّر هنا فقط
// ════════════════════════════════════════════════

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _result;
  String? _errorMsg;
  final TextEditingController _questionCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pick(ImageSource src) async {
    try {
      final f = await _picker.pickImage(source: src, imageQuality: 85);
      if (f != null) {
        setState(() {
          _image = File(f.path);
          _result = null;
          _errorMsg = null;
        });
      }
    } catch (e) {
      setState(() => _errorMsg = 'Error: $e');
    }
  }

  Future<void> _analyze() async {
    if (_image == null) return;
    final question = _questionCtrl.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _errorMsg = null;
      _result = null;
    });

    try {
      final bytes = await _image!.readAsBytes();
      final b64 = base64Encode(bytes);
      final isAr = context.read<AppProvider>().isArabic;

      final prompt = isAr
          ? '''
سؤال المستخدم عن الأكل في الصورة: "$question"

بناءً على سؤاله وما تراه في الصورة، أجب بـ JSON فقط بدون أي نص إضافي:
{"mealName":"اسم الأكل","calories":"السعرات التقريبية","isHealthy":true,"healthScore":"رقم 1-10","description":"إجابة مباشرة على سؤال المستخدم","risks":[] أو ["خطر1"] لو مش صحي,"alternatives":[] أو ["بديل1"] لو مش صحي,"nutrients":{"بروتين":"x غ","كربوهيدرات":"x غ","دهون":"x غ"}}
'''
          : '''
User question about food in image: "$question"
Respond ONLY with JSON:
{"mealName":"food name","calories":"estimated calories","isHealthy":true,"healthScore":"1-10","description":"direct answer to user","risks":[],"alternatives":[],"nutrients":{"Protein":"x g","Carbs":"x g","Fats":"x g"}}
''';

      // ── Gemini API (مجاني) ────────────────────────────────────────
      final url =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_kApiKey';

      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': b64,
                  }
                },
                {'text': prompt},
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.2,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rawText =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        // استخرج JSON من الرد
        final match = RegExp(r'\{[\s\S]*\}').firstMatch(rawText);
        if (match != null) {
          try {
            final parsed = jsonDecode(match.group(0)!) as Map<String, dynamic>;
            if (parsed['isHealthy'] is String) {
              parsed['isHealthy'] =
                  parsed['isHealthy'].toString().toLowerCase() == 'true';
            }
            setState(() => _result = parsed);
          } catch (_) {
            setState(() => _errorMsg = 'Parse error:\n$rawText');
          }
        } else {
          setState(() => _errorMsg = 'Unexpected response:\n$rawText');
        }
      } else if (res.statusCode == 400) {
        setState(() => _errorMsg =
            '❌ API Key غلط. احصل على مفتاح مجاني من:\naistudio.google.com/app/apikey');
      } else {
        final body = jsonDecode(res.body);
        setState(() => _errorMsg =
            'Error ${res.statusCode}:\n${body['error']?['message'] ?? res.body}');
      }
    } catch (e) {
      setState(() => _errorMsg = 'Network error: $e');
    }

    setState(() => _isAnalyzing = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = AppStrings.from(p.isArabic); // <- AppStrings instance
    final theme = Theme.of(context);
    final isDark = p.isDarkMode;
    final isAr = p.isArabic;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(s.cameraTitle,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF212121))),
              const SizedBox(height: 4),
              Text(s.cameraSubtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 14)),

              // ── Free badge ─────────────────────────────────────────
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.stars_rounded,
                      color: Colors.green, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    isAr ? 'من - Gemini AI' : 'From - Gemini AI',
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ]),
              ),

              const SizedBox(height: 20),

              // ── Step 1: اختار صورة ──────────────────────────────────
              if (_image == null) ...[
                _pickerCard(
                    icon: Icons.camera_alt,
                    label: s.takePhoto,
                    sub: s.takePhotoSub,
                    color: theme.colorScheme.primary,
                    onTap: () => _pick(ImageSource.camera)),
                const SizedBox(height: 12),
                _pickerCard(
                    icon: Icons.photo_library,
                    label: s.chooseGallery,
                    sub: s.chooseGallerySub,
                    color: theme.colorScheme.secondary,
                    onTap: () => _pick(ImageSource.gallery)),
              ],

              // ── Step 2: الصورة + سؤال + تحليل ──────────────────────
              if (_image != null) ...[
                ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(_image!,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                        onPressed: () => _pick(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, size: 16),
                        label: Text(s.cameraBtn)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                        onPressed: () => _pick(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library, size: 16),
                        label: Text(s.galleryBtn)),
                  ),
                ]),
                const SizedBox(height: 16),

                // ── خانة السؤال ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.help_outline,
                              color: theme.colorScheme.primary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            isAr ? 'اسأل عن الأكل ده' : 'Ask about this food',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                fontSize: 14),
                          ),
                        ]),
                        const SizedBox(height: 10),

                        // أمثلة سريعة
                        Wrap(spacing: 8, runSpacing: 6, children: [
                          _chip(isAr ? 'هل هو صحي؟' : 'Is it healthy?', theme),
                          _chip(isAr ? 'كم سعراته؟' : 'How many calories?',
                              theme),
                          _chip(isAr ? 'هل يناسب الرجيم؟' : 'Good for diet?',
                              theme),
                          _chip(
                              isAr
                                  ? 'ما فوائده الصحية؟'
                                  : 'What are its benefits?',
                              theme),
                        ]),
                        const SizedBox(height: 10),

                        TextField(
                          controller: _questionCtrl,
                          maxLines: 2,
                          textDirection:
                              isAr ? TextDirection.rtl : TextDirection.ltr,
                          decoration: InputDecoration(
                            hintText: isAr
                                ? 'مثال: لو أكلت هذا الموز هل هو صحي؟'
                                : 'If I eat this banana is it healthy?',
                            hintStyle: TextStyle(
                                color: Colors.grey[400], fontSize: 13),
                            filled: true,
                            fillColor: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey[50],
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _questionCtrl.text.trim().isEmpty
                                ? null
                                : _analyze,
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: Text(
                              isAr
                                  ? 'حلّل بالذكاء الاصطناعي '
                                  : 'Analyze with AI ',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ]),
                ),
              ],

              // ── Loading ─────────────────────────────────────────────
              if (_isAnalyzing) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2.5)),
                    const SizedBox(width: 16),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.analyzing,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary)),
                          Text(s.analyzingDetail,
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12)),
                        ]),
                  ]),
                ),
              ],

              // ── Error ───────────────────────────────────────────────
              if (_errorMsg != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.withOpacity(0.3))),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(_errorMsg!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 13))),
                      ]),
                ),
              ],

              // ── Result ──────────────────────────────────────────────
              if (_result != null && !_isAnalyzing) ...[
                const SizedBox(height: 20),
                _buildResult(theme, isDark, s, isAr),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        _questionCtrl.text = text;
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: theme.colorScheme.primary.withOpacity(0.25)),
        ),
        child: Text(text,
            style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _pickerCard({
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3))),
        child: Row(children: [
          Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 28)),
          const SizedBox(width: 16),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: color, fontSize: 16)),
              Text(sub,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ]),
          ),
          Icon(Icons.arrow_forward_ios, color: color, size: 16),
        ]),
      ),
    );
  }

  Widget _buildResult(ThemeData theme, bool isDark, AppStrings s, bool isAr) {
    final r = _result!;
    final healthy = r['isHealthy'] as bool? ?? false;
    final score = int.tryParse(r['healthScore']?.toString() ?? '5') ?? 5;
    final risks = (r['risks'] as List?) ?? [];
    final alternatives = (r['alternatives'] as List?) ?? [];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: healthy
                  ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                  : [const Color(0xFFB71C1C), const Color(0xFFE53935)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Text(healthy ? '✅' : '⚠️', style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(r['mealName'] ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                Text('${r['calories']} ${s.caloriesUnit}',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
                if ((r['description'] ?? '').toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(r['description'].toString(),
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontStyle: FontStyle.italic)),
                  ),
              ])),
          Column(children: [
            Text('$score/10',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22)),
            Text(s.score,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ]),
        ]),
      ),
      const SizedBox(height: 16),

      // ── المخاطر البدنية لو فيه ─────────────────────────────
      if (risks.isNotEmpty) ...[
        Text('${s.risks}:',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
                fontSize: 13)),
        const SizedBox(height: 4),
        Text(risks.join(', '),
            style: const TextStyle(color: Colors.red, fontSize: 13)),
        const SizedBox(height: 10),
      ],

      // ── البدائل الصحية لو فيه ─────────────────────────────
      if (alternatives.isNotEmpty) ...[
        Text('${s.alternatives}:',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
                fontSize: 13)),
        const SizedBox(height: 4),
        Text(alternatives.join(', '),
            style: const TextStyle(color: Colors.green, fontSize: 13)),
        const SizedBox(height: 10),
      ],

      // ── المغذيات ──────────────────────────────────────────
      if (r['nutrients'] != null)
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: (r['nutrients'] as Map<String, dynamic>)
                .entries
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text('${e.key}: ${e.value}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                    ))
                .toList()),
    ]);
  }
}
