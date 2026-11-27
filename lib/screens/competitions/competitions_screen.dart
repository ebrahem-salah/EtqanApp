import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/services/share_service.dart';
import '../../core/utils/app_feedback.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import 'widgets/competition_exam_sheet.dart';

class CompetitionsScreen extends StatefulWidget {
  const CompetitionsScreen({super.key});

  @override
  State<CompetitionsScreen> createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends State<CompetitionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _competitions = [];

  @override
  void initState() {
    super.initState();
    // 3 Tabs: المنتهية (0) | الجارية (1) | في الانتظار (2)
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _loadCompetitions();
  }

  Future<void> _loadCompetitions() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.getCompetitions();
      if (res.statusCode == 200 && res.data != null) {
        final List raw = res.data['data'] is List ? res.data['data'] : [];
        final parsed = raw.map<Map<String, dynamic>>((c) {
          final rawStatus = (c['status'] ?? '').toString().toLowerCase();
          final String mappedStatus;
          if (c['is_finished'] == true ||
              rawStatus == 'finished' ||
              rawStatus == 'completed' ||
              rawStatus == 'ended') {
            mappedStatus = 'finished';
          } else if (c['is_ongoing'] == true || rawStatus == 'ongoing' || rawStatus == 'active') {
            mappedStatus = 'ongoing';
          } else {
            mappedStatus = 'waiting';
          }

          final sheikhObj = c['sheikh'] ?? c['creator']?['user'] ?? c['creator'];
          return {
            'id': int.tryParse('${c['id'] ?? 0}') ?? 0,
            'title': (c['name'] ?? c['title'] ?? 'مسابقة قرآنية').toString(),
            'date': (c['starts_at'] ?? c['date'] ?? c['created_at'] ?? '').toString(),
            'duration': (c['duration_formatted'] ?? c['duration'] ?? '00:15:00').toString(),
            'subscribers_count': int.tryParse('${c['participants_count'] ?? c['students_count'] ?? c['subscribers_count'] ?? 0}') ?? 0,
            'max_subscribers': int.tryParse('${c['capacity'] ?? c['max_subscribers'] ?? c['max_students'] ?? 30}') ?? 30,
            'status': mappedStatus,
            'is_joined': c['is_enrolled'] == true || c['is_joined'] == true,
            'sheikh_name': (sheikhObj?['name'] ?? c['sheikh_name'] ?? 'مشرف المسابقة').toString(),
            'sheikh_avatar': (sheikhObj?['avatar_url'] ?? '').toString(),
            'institution_name': (c['institution']?['name'] ?? c['institution_name'] ?? 'مؤسسة إتقان').toString(),
          };
        }).toList();

        if (mounted) {
          setState(() {
            _competitions
              ..clear()
              ..addAll(parsed);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'جلب المسابقات من السيرفر', e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _shareCompetition(Map<String, dynamic> comp) {
    ShareService.shareText(
      title: comp['title'].toString(),
      text: 'شارك الآن في "${comp['title']}" على تطبيق إتقان: https://etqan.site/competitions/${comp['id']}',
    );
  }

  Future<void> _joinCompetition(Map<String, dynamic> comp) async {
    final int compId = comp['id'] as int? ?? 0;
    if (compId <= 0) return;
    try {
      await _apiClient.joinCompetition(compId);
      if (mounted) {
        AppFeedback.showSuccess(context, 'تم تسجيل انضمامك في "${comp['title']}" بنجاح');
        await _loadCompetitions();
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'الانضمام للمسابقة', e);
      }
    }
  }

  Future<void> _openCompetitionParticipants(Map<String, dynamic> comp) async {
    final int compId = comp['id'] as int? ?? 0;
    if (compId <= 0) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final bool canJudge = (auth.currentUser?.role ?? UserRole.student) != UserRole.student;

    List<Map<String, dynamic>> participants = [];
    bool loading = true;
    String? errorMsg;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            if (loading) {
              _apiClient.getCompetitionParticipants(compId).then((res) {
                final List raw = res.data?['data'] is List ? res.data['data'] : [];
                participants = raw.map<Map<String, dynamic>>((p) {
                  final u = p['student']?['user'] ?? p['user'] ?? p['student'] ?? p;
                  return {
                    'student_id': int.tryParse('${p['student_id'] ?? p['id'] ?? u['id'] ?? 0}') ?? 0,
                    'name': (u['name'] ?? p['name'] ?? 'متسابق').toString(),
                    'score': p['total_score'] ?? p['score'] ?? p['rating'] ?? 0,
                    'rank': p['rank'],
                  };
                }).toList();
                if (ctx.mounted) setSheetState(() => loading = false);
              }).catchError((e) {
                if (ctx.mounted) {
                  setSheetState(() {
                    loading = false;
                    errorMsg = AppFeedback.formatError(e);
                  });
                }
              });
            }

            return Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (canJudge)
                        TextButton.icon(
                          onPressed: () async {
                            try {
                              await _apiClient.calculateCompetitionRankings(compId);
                              if (ctx.mounted) {
                                AppFeedback.showSuccess(ctx, 'تم حساب الترتيب والنتائج النهائية');
                                setSheetState(() => loading = true);
                              }
                            } catch (e) {
                              if (ctx.mounted) AppFeedback.showError(ctx, 'حساب الترتيب', e);
                            }
                          },
                          icon: const Icon(Icons.leaderboard_rounded, size: 18, color: Color(0xFF00875A)),
                          label: const Text('حساب الترتيب', style: TextStyle(fontFamily: 'Dubai', fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      else
                        const SizedBox(width: 40),
                      Expanded(
                        child: Text(
                          'المشاركون — ${comp['title']}',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.all(28),
                      child: CircularProgressIndicator(color: Color(0xFF00875A)),
                    )
                  else if (errorMsg != null)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(errorMsg!, style: const TextStyle(fontFamily: 'Dubai', color: Colors.red)),
                    )
                  else if (participants.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'لا يوجد متسابقون مسجلون في هذه المسابقة بعد',
                        style: TextStyle(fontFamily: 'Dubai', color: Colors.grey.shade600),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: participants.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, idx) {
                          final p = participants[idx];
                          final int sid = p['student_id'] as int? ?? 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                if (canJudge && sid > 0)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00875A),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      minimumSize: Size.zero,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(bCtx);
                                      CompetitionExamSheet.show(
                                        context,
                                        competitionId: compId,
                                        studentId: sid,
                                        studentName: p['name'] ?? 'متسابق',
                                        onEvaluationSubmitted: _loadCompetitions,
                                      );
                                    },
                                    child: const Text('تقييم', style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        p['name'] ?? 'متسابق',
                                        style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        'الدرجة: ${p['score']}${p['rank'] != null ? ' • المركز #${p['rank']}' : ''}',
                                        style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // الخلفية الكريمية الرسمية من الصورة 16
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF191919)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'المسابقات',
          style: TextStyle(
            fontFamily: 'Dubai',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191919),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // 3 Tabs matching Screenshot 16: [المنتهية] [الجارية] [في الانتظار]
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF00875A), // اللون الأخضر التفاعلي من الصورة 16
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black87,
              labelStyle: const TextStyle(
                fontFamily: 'Dubai',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Dubai',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'المنتهية'),
                Tab(text: 'الجارية'),
                Tab(text: 'في الانتظار'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // محتوى التابات
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCompetitionsList('finished'),
                _buildCompetitionsList('ongoing'),
                _buildCompetitionsList('waiting'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitionsList(String filterStatus) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00875A)));
    }
    final list = _competitions.where((c) => c['status'] == filterStatus).toList();

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadCompetitions,
        color: const Color(0xFF00875A),
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.22),
            Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'لا توجد مسابقات في هذا القسم حالياً',
                style: TextStyle(
                  fontFamily: 'Dubai',
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCompetitions,
      color: const Color(0xFF00875A),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final comp = list[index];
          return _buildCompetitionCard(comp);
        },
      ),
    );
  }

  // بطاقة المسابقة المتطابقة بكسل ببكسل مع الصورة 16 (Screenshot 16)
  Widget _buildCompetitionCard(Map<String, dynamic> comp) {
    final isFinished = comp['status'] == 'finished';
    final isOngoing = comp['status'] == 'ongoing';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Row: Share Button (left) & Date/Time (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Share Button (دائرة بمحيط رمادي وأيقونة خضراء)
              GestureDetector(
                onTap: () => _shareCompetition(comp),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                  ),
                  child: const Center(
                    child: Icon(Icons.share_outlined, color: Color(0xFF00875A), size: 18),
                  ),
                ),
              ),

              // Date & Time
              Text(
                comp['date'],
                style: TextStyle(
                  fontFamily: 'Dubai',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // 2. Competition Title
          Text(
            comp['title'],
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Dubai',
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191919),
            ),
          ),

          const SizedBox(height: 6),

          // 3. Duration Row: الساعة + مدة المسابقة
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'مدة المسابقة: ${comp['duration']}',
                style: const TextStyle(
                  fontFamily: 'Dubai',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191919),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF191919)),
            ],
          ),

          const SizedBox(height: 12),

          // 4. Badges Row: [انتهت] (left) & [المشتركين 1 / 5] (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                  color: isFinished
                      ? const Color(0xFFEEEEEE)
                      : (isOngoing ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isFinished ? 'انتهت' : (isOngoing ? 'جارية الان' : 'في الانتظار'),
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isFinished
                        ? Colors.grey.shade600
                        : (isOngoing ? const Color(0xFF00875A) : Colors.orange.shade800),
                  ),
                ),
              ),

              // Subscribers Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  children: [
                    Text(
                      'المشتركين ${comp['subscribers_count']} / ${comp['max_subscribers']}',
                      style: const TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00875A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.person_outline, size: 16, color: Color(0xFF00875A)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 5. Bottom Row: [مؤسسة التعاون] (left) & Sheikh Name + Avatar (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Institution Pill (left)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF81C784)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.business_rounded, size: 15, color: Color(0xFF00875A)),
                    const SizedBox(width: 6),
                    Text(
                      comp['institution_name'],
                      style: const TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00875A),
                      ),
                    ),
                  ],
                ),
              ),

              // Sheikh Info (right)
              GestureDetector(
                onTap: () => _openCompetitionParticipants(comp),
                child: Row(
                  children: [
                    Text(
                      comp['sheikh_name'],
                      style: const TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191919),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                      ),
                      child: const Center(
                        child: Icon(Icons.person, color: Colors.grey, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF00875A)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _openCompetitionParticipants(comp),
                  icon: const Icon(Icons.groups_rounded, size: 17, color: Color(0xFF00875A)),
                  label: const Text(
                    'المتسابقون والترتيب',
                    style: TextStyle(fontFamily: 'Dubai', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00875A)),
                  ),
                ),
              ),
              if (!isFinished) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: comp['is_joined'] == true ? Colors.grey.shade400 : const Color(0xFF00875A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: comp['is_joined'] == true ? null : () => _joinCompetition(comp),
                    icon: const Icon(Icons.emoji_events_outlined, size: 17, color: Colors.white),
                    label: Text(
                      comp['is_joined'] == true ? 'منضم ✓' : 'انضمام للمسابقة',
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
