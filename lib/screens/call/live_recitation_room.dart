import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/zego_cloud_service.dart';
import '../evaluation/evaluation_rubric_screen.dart';

class LiveRecitationRoom extends StatefulWidget {
  final String roomId;
  final String circleTitle;
  final bool isSheikh;

  const LiveRecitationRoom({
    super.key,
    required this.roomId,
    required this.circleTitle,
    this.isSheikh = false,
  });

  @override
  State<LiveRecitationRoom> createState() => _LiveRecitationRoomState();
}

class _LiveRecitationRoomState extends State<LiveRecitationRoom> {
  bool _isMicMuted = false;
  bool _isSpeakerOn = true;
  String _selectedEdition = 'شمرلي'; // 'شمرلي' أو 'الملك فهد'
  int _currentPage = 293; // سورة مريم

  // Sheikh Evaluation metrics (من العقد: الخطأ، التلعثم، الصواب، أحكام التجويد)
  int _correctScore = 5;
  int _fluencyScore = 4;
  int _tajweedScore = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          children: [
            Text(
              widget.circleTitle,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const Text(
              'متصل الآن عبر ZEGOCLOUD فائقة النقاء',
              style: TextStyle(color: AppColors.gold, fontSize: 11),
            ),
          ],
        ),
        actions: [
          // ZEGOCLOUD Live Voice Call Button
          IconButton(
            icon: const Icon(Icons.headset_mic, color: Color(0xFF2ECC71)),
            tooltip: 'غرفة صوتية عبر ZEGOCLOUD',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ZegoRecitationCallPage(
                    callID: widget.roomId,
                    userID: widget.isSheikh ? 'sheikh_01' : 'student_01',
                    userName: widget.isSheikh ? 'الشيخ المشرف' : 'الطالب محمد',
                    circleTitle: widget.circleTitle,
                    isSheikh: widget.isSheikh,
                    callType: ZegoCallType.voice,
                  ),
                ),
              );
            },
          ),
          // ZEGOCLOUD Live Video Call Button
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.amber),
            tooltip: 'فيديو كول مباشر عبر ZEGOCLOUD',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ZegoRecitationCallPage(
                    callID: widget.roomId,
                    userID: widget.isSheikh ? 'sheikh_01' : 'student_01',
                    userName: widget.isSheikh ? 'الشيخ المشرف' : 'الطالب محمد',
                    circleTitle: widget.circleTitle,
                    isSheikh: widget.isSheikh,
                    callType: ZegoCallType.video,
                  ),
                ),
              );
            },
          ),
          // Quran Edition Selector (الشمرلي / الملك فهد)
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu_book, color: AppColors.gold),
            onSelected: (val) {
              setState(() {
                _selectedEdition = val;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم التحويل إلى: طبعة $val'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'الشمرلي', child: Text('طبعة الشمرلي')),
              const PopupMenuItem(value: 'مجمع الملك فهد', child: Text('طبعة مجمع الملك فهد')),
            ],
          ),
          // Sheikh Evaluation & Certificate Button
          IconButton(
            icon: const Icon(Icons.workspace_premium, color: AppColors.gold),
            tooltip: 'تقييم التلاوة وإصدار الشهادة',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EvaluationRubricScreen(
                    studentName: 'أحمد عبد المنعم موسى',
                    sheikhName: 'الشيخ عبد الله السويسي',
                    surahTested: widget.circleTitle,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quran Page View (Interactive Shared Screen)
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF7), // Paper parchment color
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                            style: TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'كهيعص ۝ ذِكْرُ رَحْمَتِ رَبِّكَ عَبْدَهُ زَكَرِيَّا ۝ إِذْ نَادَىٰ رَبَّهُ نِدَاءً خَفِيًّا ۝ قَالَ رَبِّ إِنِّي وَهَنَ الْعَظْمُ مِنِّي وَاشْتَعَلَ الرَّأْسُ شَيْبًا وَلَمْ أَكُن بِدُعَائِكَ رَبِّ شَقِيًّا ۝',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 17,
                              height: 2.2,
                              color: Colors.brown.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Edition Watermark
                  Positioned(
                    bottom: 8,
                    left: 16,
                    child: Text(
                      'طبعة: $_selectedEdition | صفحة: $_currentPage',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sheikh Live Evaluation Panel (Only for Sheikh)
          if (widget.isSheikh)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.black54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildScoreButton('الصواب', _correctScore, (v) => setState(() => _correctScore = v)),
                  _buildScoreButton('التلعثم', _fluencyScore, (v) => setState(() => _fluencyScore = v)),
                  _buildScoreButton('التجويد', _tajweedScore, (v) => setState(() => _tajweedScore = v)),
                ],
              ),
            ),

          // Audio Controls Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            color: Colors.black87,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mic Button
                IconButton(
                  icon: Icon(
                    _isMicMuted ? Icons.mic_off : Icons.mic,
                    color: _isMicMuted ? Colors.red : Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    setState(() {
                      _isMicMuted = !_isMicMuted;
                    });
                  },
                ),
                // Speaker Button
                IconButton(
                  icon: Icon(
                    _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSpeakerOn = !_isSpeakerOn;
                    });
                  },
                ),
                // End Call Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  icon: const Icon(Icons.call_end, color: Colors.white, size: 20),
                  label: const Text('مغادرة', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreButton(String label, int score, Function(int) onChanged) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Row(
          children: [
            InkWell(
              onTap: () => onChanged(score > 1 ? score - 1 : 1),
              child: const Icon(Icons.remove_circle_outline, color: Colors.white54, size: 18),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                '$score/5',
                style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            InkWell(
              onTap: () => onChanged(score < 5 ? score + 1 : 5),
              child: const Icon(Icons.add_circle_outline, color: Colors.white54, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}
