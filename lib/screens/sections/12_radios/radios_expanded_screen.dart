import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/app_colors.dart';

class RadiosExpandedScreen extends StatefulWidget {
  const RadiosExpandedScreen({super.key});

  @override
  State<RadiosExpandedScreen> createState() => _RadiosExpandedScreenState();
}

class _RadiosExpandedScreenState extends State<RadiosExpandedScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPlayingId;
  bool _isPlaying = false;
  bool _isLoadingAudio = false;

  final List<Map<String, dynamic>> _radios = [
    {
      'id': 'radio_cairo',
      'name': 'إذاعة القرآن الكريم من القاهرة',
      'country': 'مصر 🇪🇬',
      'url': 'https://backup.qurango.net/radio/tarteel',
      'desc': 'أقدم وأعرق إذاعة قرآنية في العالم العربي والإسلامي (تلاوات خاشعة ومصاحف مجودة).',
      'icon': '📻',
    },
    {
      'id': 'radio_makkah',
      'name': 'إذاعة القرآن الكريم من مكة المكرمة',
      'country': 'السعودية 🇸🇦',
      'url': 'https://backup.qurango.net/radio/saud_alshuraim',
      'desc': 'بث حي ومباشر على مدار الساعة لصلوات وتلاوات الحرمين الشريفين.',
      'icon': '🕋',
    },
    {
      'id': 'radio_riyadh',
      'name': 'إذاعة القرآن الكريم من الرياض',
      'country': 'السعودية 🇸🇦',
      'url': 'https://backup.qurango.net/radio/abdurrahman_alsudais',
      'desc': 'برامج وتلاوات وتفاسير وقراءات خاشعة على مدار 24 ساعة.',
      'icon': '📻',
    },
    {
      'id': 'radio_minshawi',
      'name': 'إذاعة الشيخ محمد صديق المنشاوي',
      'country': 'المصحف المرتل والمجود 🎙️',
      'url': 'https://backup.qurango.net/radio/mohammed_siddiq_alminshawi_mojawwad',
      'desc': 'تلاوات متصلة للشيخ المنشاوي صاحب الصوت الباكي الخاشع.',
      'icon': '🎙️',
    },
    {
      'id': 'radio_abdulbasit',
      'name': 'إذاعة الشيخ عبد الباسط عبد الصمد',
      'country': 'الحناجر الذهبية 🎙️',
      'url': 'https://backup.qurango.net/radio/abdulbasit_abdulsamad_mojawwad',
      'desc': 'روائع التلاوات والمحافل القرآنية التاريخية للشيخ عبد الباسط.',
      'icon': '🎙️',
    },
    {
      'id': 'radio_hussary',
      'name': 'إذاعة الشيخ محمود خليل الحصري',
      'country': 'شيخ عموم المقارئ 🎙️',
      'url': 'https://backup.qurango.net/radio/mahmoud_khalil_alhussary_mojawwad',
      'desc': 'المصحف المرتل والمجود بروايات حفص وورش وقالون والدوري.',
      'icon': '🎙️',
    },
    {
      'id': 'radio_alafasi',
      'name': 'إذاعة الشيخ مشاري راشد العفاسي',
      'country': 'تلاوات عذبة 🎙️',
      'url': 'https://backup.qurango.net/radio/mishary_alafasi',
      'desc': 'المصحف المرتل كاملاً بصوت الشيخ مشاري العفاسي.',
      'icon': '🎙️',
    },
    {
      'id': 'radio_ajmy',
      'name': 'إذاعة الشيخ أحمد بن علي العجمي',
      'country': 'تلاوات خاشعة 🎙️',
      'url': 'https://backup.qurango.net/radio/ahmad_alajmy',
      'desc': 'تلاوات مؤثرة من صلوات التراويح والمصحف المرتل.',
      'icon': '🎙️',
    },
    {
      'id': 'radio_qatami',
      'name': 'إذاعة الشيخ ناصر القطامي',
      'country': 'تلاوات نادية 🎙️',
      'url': 'https://backup.qurango.net/radio/nasser_alqatami',
      'desc': 'قراءات خاشعة ومتنوعة لجميع سور القرآن الكريم.',
      'icon': '🎙️',
    },
    {
      'id': 'radio_dosari',
      'name': 'إذاعة الشيخ ياسر الدوسري',
      'country': 'أئمة الحرم المكي 🕋',
      'url': 'https://backup.qurango.net/radio/yasser_aldosari',
      'desc': 'تلاوات الحرم المكي الشريف وسور القرآن الكريم.',
      'icon': '🕋',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAudioSession();
  }

  Future<void> _initAudioSession() async {
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {
              AVAudioSessionOptions.defaultToSpeaker,
            },
          ),
        ),
      );

      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (!mounted) return;
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (state == PlayerState.playing || state == PlayerState.paused || state == PlayerState.stopped) {
            _isLoadingAudio = false;
          }
        });
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayRadio(Map<String, dynamic> radio) async {
    final id = radio['id'] as String;
    if (_currentPlayingId == id && _isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
      return;
    }

    setState(() {
      _currentPlayingId = id;
      _isLoadingAudio = true;
    });

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(UrlSource(radio['url']));
      if (mounted) {
        setState(() {
          _isPlaying = true;
          _isLoadingAudio = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoadingAudio = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر تشغيل بث ${radio['name']}. يرجى التحقق من اتصال الإنترنت.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'الإذاعات الإسلامية وقنوات البث',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _radios.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, idx) {
          final r = _radios[idx];
          final bool isCurrent = _currentPlayingId == r['id'];
          final bool isPlayingThis = isCurrent && _isPlaying;
          final bool isLoadingThis = isCurrent && _isLoadingAudio;

          return Container(
            decoration: BoxDecoration(
              color: isPlayingThis ? const Color(0xFFE8F5E9) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPlayingThis ? const Color(0xFF00875A) : Colors.grey.shade200,
                width: isPlayingThis ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isPlayingThis ? const Color(0xFF00875A) : const Color(0xFFF1F8F5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  r['icon'],
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      r['name'],
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isPlayingThis ? const Color(0xFF00875A) : Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPlayingThis ? Colors.green.shade700 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      r['country'],
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 10,
                        color: isPlayingThis ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  r['desc'],
                  style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              trailing: SizedBox(
                width: 48,
                height: 48,
                child: isLoadingThis
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF00875A)),
                      )
                    : IconButton(
                        icon: Icon(
                          isPlayingThis ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                          color: isPlayingThis ? const Color(0xFF00875A) : const Color(0xFF2E7D32),
                          size: 38,
                        ),
                        onPressed: () => _togglePlayRadio(r),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
