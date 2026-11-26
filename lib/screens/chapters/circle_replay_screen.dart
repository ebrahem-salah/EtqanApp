import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/services/share_service.dart';
import '../../core/utils/app_feedback.dart';

class CircleReplayScreen extends StatefulWidget {
  final Map<String, dynamic> chapter;

  const CircleReplayScreen({
    super.key,
    required this.chapter,
  });

  @override
  State<CircleReplayScreen> createState() => _CircleReplayScreenState();
}

class _CircleReplayScreenState extends State<CircleReplayScreen>
    with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  late TabController _tabController;

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(minutes: 3);

  List<Map<String, dynamic>> _messages = [];
  bool _isLoadingMessages = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initPlayer();
    _loadChatHistory();
  }

  void _initPlayer() {
    final String? recordUrl = widget.chapter['record_url'];
    if (recordUrl != null && recordUrl.isNotEmpty && recordUrl.startsWith('http')) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(recordUrl))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
              _totalDuration = _videoController!.value.duration;
            });
            _videoController!.addListener(_onVideoUpdate);
          }
        }).catchError((_) {
          _initMockPlayer();
        });
    } else {
      _initMockPlayer();
    }
  }

  void _initMockPlayer() {
    // Mock simulation for recitation replay
    if (mounted) {
      setState(() {
        _isVideoInitialized = true;
        _totalDuration = const Duration(minutes: 3, seconds: 0);
      });
    }
  }

  void _onVideoUpdate() {
    if (_videoController != null && mounted) {
      setState(() {
        _currentPosition = _videoController!.value.position;
        _isPlaying = _videoController!.value.isPlaying;
      });
    }
  }

  Future<void> _loadChatHistory() async {
    final int? classId = widget.chapter['id'] is int
        ? widget.chapter['id'] as int
        : int.tryParse('${widget.chapter['id']}');
    if (classId == null) return;
    setState(() => _isLoadingMessages = true);
    try {
      final res = await _apiClient.getClassMessages(classId);
      if (res.statusCode == 200 && res.data != null) {
        final List list = res.data['data'] ?? [];
        if (mounted) {
          setState(() {
            _messages = list.map<Map<String, dynamic>>((m) {
              final senderObj = m['sender'] ?? m['user'] ?? {};
              final role = (senderObj['user_type'] ?? senderObj['type'] ?? senderObj['role'] ?? '')
                  .toString()
                  .toLowerCase();
              final createdRaw = (m['created_at_human'] ?? m['created_at'] ?? '').toString();
              final String timeText = createdRaw.length >= 16 && createdRaw.contains('T')
                  ? createdRaw.substring(11, 16)
                  : createdRaw;
              return {
                'sender': senderObj['name']?.toString() ?? 'مشارك',
                'text': (m['message'] ?? m['text'] ?? '').toString(),
                'time': timeText,
                'isSheikh': role == 'sheikh' || role == 'teacher' || role == 'admin' || role == 'supervisor',
              };
            }).toList();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'تحميل سجل المحادثة', e);
      }
    }

    if (mounted) setState(() => _isLoadingMessages = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_videoController != null) {
      _videoController!.removeListener(_onVideoUpdate);
      _videoController!.dispose();
    }
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      if (_isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    } else {
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }
  }

  void _changeSpeed() {
    final speeds = [1.0, 1.25, 1.5, 2.0];
    int nextIdx = (speeds.indexOf(_playbackSpeed) + 1) % speeds.length;
    final newSpeed = speeds[nextIdx];
    setState(() => _playbackSpeed = newSpeed);
    _videoController?.setPlaybackSpeed(newSpeed);
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.chapter['title'] ?? 'تسجيل الحلقة';
    final supervisor = widget.chapter['supervisor'] ?? 'الشيخ المقرئ';
    final time = widget.chapter['time'] ?? '16/11/2026';
    final duration = widget.chapter['duration'] ?? '00:03:00';

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // الخلفية الكريمية الرسمية
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF191919)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Dubai',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191919),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF00875A)),
              onPressed: () {
                ShareService.shareText(
                  title: title,
                  text: 'استمع إلى تسجيل حلقة "$title" على تطبيق إتقان: https://etqan.site/classes/${widget.chapter['id']}',
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Replay Video/Audio Player Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    // Video View or Clean Audio Recitation Background
                    if (_videoController != null && _videoController!.value.isInitialized)
                      VideoPlayer(_videoController!)
                    else
                      Container(
                        color: const Color(0xFF1B2A22),
                        child: const Align(
                          alignment: Alignment(0, 0.56),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.graphic_eq_rounded, color: Color(0xFF00C48C), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'تسجيل تلاوة الجلسة',
                                style: TextStyle(
                                  fontFamily: 'Dubai',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Top Bar inside Player: Speed Badge & Recorded Badge
                    Positioned(
                      top: 10,
                      left: 12,
                      right: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Playback Speed Button
                          GestureDetector(
                            onTap: _changeSpeed,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white30),
                              ),
                              child: Text(
                                '${_playbackSpeed}x',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          // Red Recorded Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'تسجيل محفوظ',
                                  style: TextStyle(
                                    fontFamily: 'Dubai',
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.fiber_manual_record, color: Colors.white, size: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Central Play / Pause Button
                    Center(
                      child: GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                    ),

                    // Bottom Scrubber & Timestamps
                    Positioned(
                      bottom: 8,
                      left: 12,
                      right: 12,
                      child: Row(
                        children: [
                          Text(
                            _formatDuration(_currentPosition),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                                activeTrackColor: const Color(0xFF00875A),
                                inactiveTrackColor: Colors.white30,
                                thumbColor: Colors.white,
                              ),
                              child: Slider(
                                value: _currentPosition.inSeconds.toDouble().clamp(
                                      0.0,
                                      _totalDuration.inSeconds.toDouble() > 0
                                          ? _totalDuration.inSeconds.toDouble()
                                          : 1.0,
                                    ),
                                min: 0.0,
                                max: _totalDuration.inSeconds.toDouble() > 0
                                    ? _totalDuration.inSeconds.toDouble()
                                    : 1.0,
                                onChanged: (val) {
                                  final newPos = Duration(seconds: val.toInt());
                                  if (_videoController != null &&
                                      _videoController!.value.isInitialized) {
                                    _videoController!.seekTo(newPos);
                                  } else {
                                    setState(() => _currentPosition = newPos);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDuration(_totalDuration),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Info Header (Sheikh, Time, Institution)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF00875A).withOpacity(0.1),
                    child: const Icon(Icons.person, color: Color(0xFF00875A), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supervisor,
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF191919),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 13, color: Colors.grey),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'المدة: $duration | $time',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3EADB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'مؤسسة التعاون',
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00875A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Segmented Tabs: [سجل المحادثة] و [المشتركون والملاحظات]
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelPadding: const EdgeInsets.symmetric(horizontal: 6),
              indicator: BoxDecoration(
                color: const Color(0xFF00875A),
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black87,
              labelStyle: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 12),
              tabs: const [
                Tab(text: 'سجل المحادثة 💬'),
                Tab(text: 'المشاركون والملاحظات 📋'),
              ],
            ),
          ),

          // 4. Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Chat History
                _isLoadingMessages
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF00875A)))
                    : _messages.isEmpty
                        ? Center(
                            child: Text(
                              'لا توجد رسائل مسجلة لهذه الحلقة',
                              style: TextStyle(fontFamily: 'Dubai', fontSize: 14, color: Colors.grey.shade600),
                            ),
                          )
                        : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isSheikh = msg['isSheikh'] == true;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSheikh ? const Color(0xFFE5EFE9) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSheikh ? const Color(0xFF00875A).withOpacity(0.2) : Colors.grey.shade200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      msg['sender'],
                                      style: TextStyle(
                                        fontFamily: 'Dubai',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isSheikh ? const Color(0xFF00875A) : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      msg['time'],
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg['text'],
                                  style: const TextStyle(
                                    fontFamily: 'Dubai',
                                    fontSize: 13,
                                    color: Color(0xFF2C2C2C),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                // Tab 2: Attendees & Notes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📌 ملاحظات وتوجيهات الشيخ للمشاركين:',
                              style: TextStyle(
                                fontFamily: 'Dubai',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF00875A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (widget.chapter['notes']?.toString().isNotEmpty == true)
                                  ? widget.chapter['notes'].toString()
                                  : 'لا توجد ملاحظات مسجلة من الشيخ لهذه الجلسة.',
                              style: const TextStyle(fontFamily: 'Dubai', fontSize: 13, height: 1.6),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '👥 المشاركون في الجلسة:',
                              style: TextStyle(
                                fontFamily: 'Dubai',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF191919),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildAttendeeTile(
                              supervisor,
                              'مشرف الحلقة (${widget.chapter['subscribers'] ?? '0'})',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeeTile(String name, String grade) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF00875A).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 18, color: Color(0xFF00875A)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  grade,
                  style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
