import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/zego_cloud_service.dart';

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
  bool _isHandRaised = false;
  bool _isStudentMicApproved = false;

  int _currentAyahIndex = 1;

  final List<String> _ayahs = [
    'كٓهيعٓصٓ ۝١',
    'ذِكْرُ رَحْمَتِ رَبِّكَ عَبْدَهُۥ زَكَرِيَّآ ۝٢',
    'إِذْ نَادَىٰ رَبَّهُۥ نِدَآءً خَفِيًّۭا ۝٣',
    'قَالَ رَبِّ إِنِّى وَهَنَ ٱلْعَظْمُ مِنِّى وَٱشْتَعَلَ ٱلرَّأْسُ شَيْبًۭا ۝٤',
    'وَلَمْ أَكُنۢ بِدُعَآئِكَ رَبِّ شَقِيًّۭا ۝٥',
    'وَإِنِّى خِفْتُ ٱلْمَوَٰلِىَ مِن وَرَآءِى وَكَانَتِ ٱمْرَأَتِى عَاقِرًۭا فَهَبْ لِى مِن لَّدُنكَ وَلِيًّۭا ۝٦',
  ];

  void _toggleRaiseHand() {
    setState(() {
      _isHandRaised = !_isHandRaised;
    });

    if (_isHandRaised) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✋ تم رفع يدك! بانتظار إذن فضيلة الشيخ للتسميع...'),
          backgroundColor: Color(0xFFD4AF37),
        ),
      );

      // محاكاة موافقة الشيخ التلقائية بعد ثانيتين
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _isStudentMicApproved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ وافق الشيخ عبد الله على طلبك! المايك مفتوح لك الآن للتسميع.'),
            backgroundColor: Color(0xFF00875A),
          ),
        );
      });
    } else {
      setState(() {
        _isStudentMicApproved = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141F18),
      appBar: AppBar(
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          children: [
            Text(
              widget.circleTitle,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const Text(
              'متصل عبر ZEGOCLOUD (صوت فائق النقاء 48kHz)',
              style: TextStyle(color: Color(0xFF2ECC71), fontSize: 10),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_in_picture, color: Color(0xFFFFDF73)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📱 يستمر البث الصوتي بالخلفية.')),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط المتحدث الحالي
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF0C140F),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFF00875A),
                      child: Text(_isStudentMicApproved ? '👤' : '👳‍♂️', style: const TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isStudentMicApproved
                          ? 'الطالب أحمد يتحدث ويسمع الآن 🎙️'
                          : 'الشيخ عبد الله السويسي يتحدث الآن 🎙️',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Text('👥 28 طالباً', style: TextStyle(color: Colors.amber, fontSize: 11)),
              ],
            ),
          ),

          // صفحة المصحف الشريف المتزامن مع التلاوة
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        '📖 سورة مريم (مكية) - الآيات 1 إلى 6',
                        style: TextStyle(color: Color(0xFF6D4C41), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'طبعة الشمرلي الأصلية',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          runSpacing: 8,
                          children: List.generate(_ayahs.length, (index) {
                            final isHighlighted = index + 1 == _currentAyahIndex;
                            return InkWell(
                              onTap: () => setState(() => _currentAyahIndex = index + 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isHighlighted ? const Color(0xFFFFE899) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _ayahs[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 2.2,
                                    fontFamily: 'Amiri',
                                    fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                                    color: isHighlighted ? const Color(0xFF3B2C00) : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),

                  // تقييم التجويد المباشر للشيخ
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF8ED),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Text('التجويد: 5/5 ⭐', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00875A))),
                        Text('المخارج: 5/5 ⭐', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00875A))),
                        Text('التقييم: 100%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // زر رفع اليد للطلب من الشيخ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: const Color(0xFF101C14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'طلب التسميع أمام الشيخ:',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isHandRaised ? Colors.amber : const Color(0xFF00875A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _toggleRaiseHand,
                  icon: const Icon(Icons.pan_tool, size: 16, color: Colors.white),
                  label: Text(
                    _isHandRaised ? 'خفض اليد ✋' : 'رفع اليد للتسميع ✋',
                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // أدوات التحكم (مايك، سماعة، إنهاء)
          Container(
            padding: const EdgeInsets.all(14),
            color: Colors.black87,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  iconSize: 32,
                  icon: Icon(
                    _isMicMuted ? Icons.mic_off : Icons.mic,
                    color: _isStudentMicApproved ? const Color(0xFF2ECC71) : Colors.white,
                  ),
                  onPressed: () {
                    if (!_isStudentMicApproved) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🔒 يرجى رفع اليد أولاً ليأذن لك الشيخ بالتسميع.')),
                      );
                      return;
                    }
                    setState(() => _isMicMuted = !_isMicMuted);
                  },
                ),
                IconButton(
                  iconSize: 32,
                  icon: Icon(_isSpeakerOn ? Icons.volume_up : Icons.volume_off, color: Colors.white),
                  onPressed: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                ),
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.call_end, color: Colors.red),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
