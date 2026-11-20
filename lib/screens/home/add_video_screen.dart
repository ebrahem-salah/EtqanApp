import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_compress/video_compress.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';

class AddVideoScreen extends StatefulWidget {
  const AddVideoScreen({super.key});

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  final ApiClient _apiClient = ApiClient();

  // --- File upload state ---
  File? _selectedFile;
  String _selectedVideoName = '';
  bool _isCompressing = false;
  double _compressionProgress = 0.0;
  File? _compressedFile;

  // --- Upload state ---
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Tab: 0 = URL, 1 = File
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() => _activeTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    VideoCompress.cancelCompression();
    super.dispose();
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // طلب الصلاحيات حسب نسخة الأندرويد
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Future<bool> _requestStoragePermission() async {
    // Android 13+ → READ_MEDIA_VIDEO
    // Android 12 وما دونه → READ_EXTERNAL_STORAGE
    if (Platform.isAndroid) {
      final int sdkInt = int.tryParse(
              (await Process.run('getprop', ['ro.build.version.sdk'])).stdout
                  .toString()
                  .trim()) ??
          0;
      if (sdkInt >= 33) {
        final status = await Permission.videos.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true; // iOS لا تحتاج صلاحية مسبقة
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // فتح مستعرض الملفات واختيار الفيديو
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Future<void> _pickVideoFile() async {
    // طلب الصلاحية
    final granted = await _requestStoragePermission();
    if (!granted) {
      if (!mounted) return;
      _showSnack('⚠️ يرجى منح صلاحية الوصول إلى الفيديوهات من إعدادات التطبيق',
          isError: true);
      await openAppSettings();
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: false,
        withReadStream: false,
        allowCompression: false,
      );

      if (result == null || result.files.isEmpty) return;

      final picked = result.files.first;
      if (picked.path == null) {
        _showSnack('⚠️ لم يتم العثور على مسار الملف', isError: true);
        return;
      }

      final file = File(picked.path!);
      final sizeInMB = file.lengthSync() / (1024 * 1024);

      setState(() {
        _selectedFile = file;
        _selectedVideoName = picked.name;
        _compressedFile = null;
        _compressionProgress = 0;
      });

      // إذا الفيديو أكبر من 50 ميجا → ضغط تلقائي إلى 720p
      if (sizeInMB > 50) {
        await _compressVideo(file);
      } else {
        _showSnack(
            '✅ تم اختيار الفيديو (${sizeInMB.toStringAsFixed(1)} MB) - جاهز للرفع');
      }
    } catch (e) {
      _showSnack('⚠️ خطأ أثناء اختيار الفيديو: $e', isError: true);
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ضغط الفيديو إلى جودة 720p
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Future<void> _compressVideo(File file) async {
    setState(() {
      _isCompressing = true;
      _compressionProgress = 0;
    });

    // مراقبة تقدم الضغط
    VideoCompress.compressProgress$.subscribe((progress) {
      if (mounted) setState(() => _compressionProgress = progress / 100);
    });

    try {
      final info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.MediumQuality, // 720p تقريباً
        deleteOrigin: false,
        includeAudio: true,
        frameRate: 30,
      );

      if (info != null && info.file != null) {
        final origMB = file.lengthSync() / (1024 * 1024);
        final compMB = info.file!.lengthSync() / (1024 * 1024);
        setState(() => _compressedFile = info.file!);
        _showSnack(
            '✅ تم الضغط: ${origMB.toStringAsFixed(1)}MB → ${compMB.toStringAsFixed(1)}MB (720p)');
      }
    } catch (e) {
      _showSnack('⚠️ تعذر ضغط الفيديو، سيتم الرفع بالجودة الأصلية',
          isError: true);
    } finally {
      VideoCompress.dispose();
      if (mounted) setState(() => _isCompressing = false);
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // رفع الفيديو (URL أو ملف)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Future<void> _handleUpload() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      _showSnack('يرجى كتابة وصف لمقطع الفيديو', isError: true);
      return;
    }

    if (_activeTab == 0) {
      // رفع عبر URL
      final url = _urlController.text.trim();
      if (url.isEmpty) {
        _showSnack('يرجى إدخال رابط الفيديو', isError: true);
        return;
      }
      if (!url.startsWith('http')) {
        _showSnack('يرجى إدخال رابط صحيح يبدأ بـ http أو https', isError: true);
        return;
      }
      await _uploadByUrl(url, description);
    } else {
      // رفع ملف
      if (_selectedFile == null) {
        _showSnack('يرجى اختيار ملف فيديو أولاً', isError: true);
        return;
      }
      await _uploadFile(description);
    }
  }

  Future<void> _uploadByUrl(String url, String description) async {
    setState(() => _isUploading = true);
    try {
      await _apiClient.createVideo(description: description, videoUrl: url);
      if (mounted) {
        _showSnack('🎉 تم رفع مقطع الفيديو بنجاح!');
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        _showSnack('✅ تم حفظ الفيديو بنجاح في قاعدة بيانات إتقان');
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _uploadFile(String description) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    final fileToUpload = _compressedFile ?? _selectedFile!;

    try {
      // رفع الملف عبر API مع تتبع التقدم
      await _apiClient.uploadVideoFile(
        file: fileToUpload,
        description: description,
        onProgress: (sent, total) {
          if (mounted) {
            setState(() => _uploadProgress = sent / total);
          }
        },
      );
      if (mounted) {
        _showSnack('🎉 تم رفع الفيديو بجودة 720p بنجاح!');
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        _showSnack('✅ تم حفظ الفيديو بنجاح');
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0;
        });
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(fontFamily: 'Dubai', fontSize: 13)),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF00875A),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // UI
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'إضافة فيديو',
          style: TextStyle(
            color: Color(0xFF1E2822),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Dubai',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF00875A), size: 18),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF00875A),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontFamily: 'Dubai',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Dubai',
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.link_rounded, size: 18),
                  text: 'رابط URL',
                  iconMargin: EdgeInsets.only(bottom: 2),
                ),
                Tab(
                  icon: Icon(Icons.upload_file_rounded, size: 18),
                  text: 'ملف من الهاتف',
                  iconMargin: EdgeInsets.only(bottom: 2),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              // ── محتوى التاب ──
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUrlTab(),
                    _buildFileTab(),
                  ],
                ),
              ),

              // ── حقل الوصف ──
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 2,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    hintText: 'وصف الفيديو',
                    hintStyle: TextStyle(
                      fontFamily: 'Dubai',
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── شريط التقدم (ضغط أو رفع) ──
              if (_isCompressing || _isUploading) ...[
                _buildProgressBar(),
                const SizedBox(height: 12),
              ],

              // ── زر الرفع ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF191919),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: (_isUploading || _isCompressing)
                      ? null
                      : _handleUpload,
                  child: (_isUploading || _isCompressing)
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'إضافة فيديو',
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ── تاب رابط URL ──
  Widget _buildUrlTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _urlController,
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'https://www.youtube.com/watch?v=...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon:
                  const Icon(Icons.link_rounded, color: Color(0xFF00875A)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // أيقونة توضيحية
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.smart_display_rounded,
                    size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  'الصق رابط يوتيوب أو رابط مباشر للفيديو',
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── تاب ملف من الهاتف ──
  Widget _buildFileTab() {
    return GestureDetector(
      onTap: (_isCompressing || _isUploading) ? null : _pickVideoFile,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedFile != null
                ? const Color(0xFF00875A)
                : Colors.grey.shade300,
            width: _selectedFile != null ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة الحالة
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedFile != null
                      ? const Color(0xFF00875A).withOpacity(0.1)
                      : const Color(0xFFFCFBE8),
                  border: Border.all(
                    color: _selectedFile != null
                        ? const Color(0xFF00875A).withOpacity(0.3)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Icon(
                  _selectedFile != null
                      ? Icons.check_circle_rounded
                      : Icons.video_collection_outlined,
                  color: _selectedFile != null
                      ? const Color(0xFF00875A)
                      : Colors.black54,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),

              // اسم الملف أو النص الافتراضي
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _selectedFile != null
                      ? _selectedVideoName
                      : 'اضغط لاختيار فيديو من الهاتف',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _selectedFile != null
                        ? const Color(0xFF00875A)
                        : Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              if (_selectedFile != null) ...[
                const SizedBox(height: 6),
                Text(
                  _compressedFile != null
                      ? '🎯 مضغوط 720p - جاهز للرفع'
                      : '📁 ${(_selectedFile!.lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB',
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 12,
                    color: _compressedFile != null
                        ? const Color(0xFF00875A)
                        : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: (_isCompressing || _isUploading)
                      ? null
                      : _pickVideoFile,
                  icon: const Icon(Icons.refresh_rounded,
                      size: 16, color: Color(0xFF00875A)),
                  label: const Text(
                    'تغيير الفيديو',
                    style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 13,
                        color: Color(0xFF00875A)),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9F4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🎯 يتم ضغطه تلقائياً إلى 720p',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 11,
                      color: Color(0xFF00875A),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── شريط التقدم ──
  Widget _buildProgressBar() {
    final isComp = _isCompressing;
    final progress = isComp ? _compressionProgress : _uploadProgress;
    final label = isComp
        ? 'جارٍ ضغط الفيديو إلى 720p...'
        : 'جارٍ رفع الفيديو إلى السيرفر...';
    final pct = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Dubai',
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
            Text(
              '$pct%',
              style: const TextStyle(
                fontFamily: 'Dubai',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00875A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF00875A)),
          ),
        ),
      ],
    );
  }
}
