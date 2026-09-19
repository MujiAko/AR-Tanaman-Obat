import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../controller/scan_controller.dart';
import '../data/herbal_data.dart';
import '../service/plant_classifier_service.dart';
import '../theme/app_theme.dart';
import '../widget/ar_overlay.dart';
import '../widget/plant_thumb.dart';
import 'plant_detail_page.dart';

/// Page 2 — Kamera Pindai AR (Real-Time Live Viewfinder)
///
/// - Tombol rana: ambil satu foto lalu identifikasi.
/// - Mode Live: memindai otomatis setiap ±2,5 detik dan memperbarui label AR.
/// - Galeri: identifikasi dari foto yang sudah ada.
class ScanPage extends StatefulWidget {
  final VoidCallback onClose;

  const ScanPage({super.key, required this.onClose});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  static const _liveInterval = Duration(milliseconds: 2500);

  final ImagePicker _picker = ImagePicker();

  CameraController? _cam;
  String? _camError;
  bool _settingUp = false;
  bool _initializing = true;

  bool _busy = false;
  bool _live = false;
  Timer? _liveTimer;

  File? _still; // foto beku (dari rana atau galeri)
  File? _lastFile; // foto terakhir yang menghasilkan _result
  ClassificationResult? _result;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<ScanController>().init();
    _setupCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _liveTimer?.cancel();
    final c = _cam;
    _cam = null;
    c?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final c = _cam;
      if (c != null) {
        _stopLive();
        setState(() => _cam = null);
        c.dispose();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_cam == null && !_settingUp) _setupCamera();
    }
  }

  // ---------------------------------------------------------------- kamera

  Future<void> _setupCamera() async {
    _settingUp = true;
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        throw CameraException('none', 'Perangkat ini tidak memiliki kamera.');
      }
      final back = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );
      final ctrl = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        _cam = ctrl;
        _camError = null;
        _initializing = false;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      final denied = e.code.toLowerCase().contains('denied');
      setState(() {
        _initializing = false;
        _camError = denied
            ? 'Izin kamera ditolak. Aktifkan izin kamera di Pengaturan, atau pilih foto dari galeri.'
            : (e.description ?? 'Kamera tidak dapat dibuka (${e.code}).');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _camError = 'Kamera tidak dapat dibuka: $e';
      });
    } finally {
      _settingUp = false;
    }
  }

  // ------------------------------------------------------------ identifikasi

  Future<void> _scanFromCamera({bool silent = false}) async {
    final c = _cam;
    if (c == null || !c.value.isInitialized) return;
    if (_busy || c.value.isTakingPicture) return;
    final scan = context.read<ScanController>();

    setState(() => _busy = true);
    try {
      final shot = await c.takePicture();
      final file = File(shot.path);
      final res = await scan.classify(file);
      if (!mounted) return;
      _rememberFile(file);
      setState(() {
        _result = res;
        if (!silent) _still = file;
      });
    } catch (e) {
      if (mounted && !silent) _showError('Gagal mengidentifikasi: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_busy) return;
    _stopLive();
    final scan = context.read<ScanController>();
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 90,
      );
      if (x == null || !mounted) return;
      final file = File(x.path);
      setState(() {
        _busy = true;
        _still = file;
        _result = null;
      });
      final res = await scan.classify(file);
      if (!mounted) return;
      _rememberFile(file);
      setState(() => _result = res);
    } catch (e) {
      if (mounted) _showError('Gagal mengidentifikasi: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Simpan foto terakhir; hapus foto sementara sebelumnya agar cache tidak menumpuk.
  void _rememberFile(File file) {
    final old = _lastFile;
    _lastFile = file;
    if (old != null && old.path != file.path) {
      old.delete().catchError((_) => old);
    }
  }

  void _reset() {
    setState(() {
      _still = null;
      _result = null;
    });
  }

  // -------------------------------------------------------------- mode live

  void _toggleLive() {
    if (_live) {
      _stopLive();
    } else {
      if (_cam == null) return;
      setState(() {
        _live = true;
        _still = null;
      });
      _liveTimer = Timer.periodic(
        _liveInterval,
        (_) => _scanFromCamera(silent: true),
      );
      _scanFromCamera(silent: true);
    }
  }

  void _stopLive() {
    _liveTimer?.cancel();
    _liveTimer = null;
    if (mounted && _live) setState(() => _live = false);
  }

  // ------------------------------------------------------------------- misc

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openDetail(HerbalPlant plant) {
    _stopLive();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlantDetailPage(
          plant: plant,
          scanImage: _lastFile,
          confidence: _result?.confidence,
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final plant = (result != null && result.isRecognized)
        ? HerbalData.byLabel(result.label)
        : null;
    final recognized = plant != null;

    return LayoutBuilder(
      builder: (context, box) {
        final size = box.biggest;
        final side = math.min(size.width * 0.74, size.height * 0.40);
        final frame = Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.38),
          width: side,
          height: side,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            _buildViewfinder(),
            const IgnorePointer(child: _EdgeShade()),
            if (_cam != null || _still != null)
              IgnorePointer(
                child: CustomPaint(
                  painter: BracketPainter(
                    frame: frame,
                    color: _result == null
                        ? Colors.white
                        : (recognized ? const Color(0xFF9BE28E) : AppColors.amber),
                  ),
                ),
              ),
            if (_busy || _result != null)
              Positioned(
                top: frame.center.dy - 80,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(child: _buildArLabel(plant)),
                ),
              ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    _RoundButton(
                      icon: Icons.close_rounded,
                      tooltip: 'Tutup kamera',
                      onTap: widget.onClose,
                    ),
                    const Expanded(
                      child: Text(
                        'Pindai tanaman',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_result != null && (!_busy || _live))
                    _ResultCard(
                      plant: plant,
                      result: _result!,
                      photo: _lastFile,
                      onDetail: plant == null ? null : () => _openDetail(plant),
                    ),
                  const SizedBox(height: 16),
                  _buildControls(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildViewfinder() {
    final still = _still;
    if (still != null) {
      return Image.file(still, fit: BoxFit.cover);
    }
    final c = _cam;
    if (c != null && c.value.isInitialized) {
      final preview = c.value.previewSize!;
      return ClipRect(
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: preview.height,
              height: preview.width,
              child: CameraPreview(c),
            ),
          ),
        ),
      );
    }
    return Container(
      color: const Color(0xFF14201A),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: _initializing
          ? const CircularProgressIndicator(color: Colors.white)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.no_photography_rounded,
                    color: Colors.white70, size: 44),
                const SizedBox(height: 14),
                Text(
                  _camError ?? 'Kamera tidak tersedia.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Pilih dari galeri'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildArLabel(HerbalPlant? plant) {
    final r = _result;
    if (r == null) {
      return const ArLabel(title: 'Menganalisis…', busy: true);
    }
    if (plant != null) {
      return ArLabel(
        title: plant.name,
        subtitle: 'Keyakinan ${r.confidencePercentText}',
      );
    }
    return const ArLabel(
      title: 'Belum dikenali',
      subtitle: 'Arahkan ke satu tanaman',
      warning: true,
    );
  }

  Widget _buildControls() {
    final hasStill = _still != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _RoundButton(
          icon: Icons.photo_library_rounded,
          tooltip: 'Pilih dari galeri',
          size: 52,
          onTap: _pickFromGallery,
        ),
        Semantics(
          button: true,
          label: hasStill ? 'Pindai ulang' : 'Ambil foto dan identifikasi',
          child: GestureDetector(
            onTap: hasStill ? _reset : () => _scanFromCamera(),
            child: Container(
              width: 78,
              height: 78,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: hasStill ? AppColors.forest : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: _busy && !_live
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.forest,
                        ),
                      )
                    : hasStill
                        ? const Icon(Icons.refresh_rounded,
                            color: Colors.white, size: 30)
                        : null,
              ),
            ),
          ),
        ),
        _RoundButton(
          icon: _live ? Icons.sensors_rounded : Icons.sensors_off_rounded,
          tooltip: _live ? 'Matikan mode live' : 'Nyalakan mode live',
          size: 52,
          active: _live,
          onTap: _toggleLive,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- widgets

class _EdgeShade extends StatelessWidget {
  const _EdgeShade();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x99000000),
            Color(0x00000000),
            Color(0x00000000),
            Color(0xB3000000),
          ],
          stops: [0.0, 0.22, 0.55, 1.0],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final double size;
  final bool active;

  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 44,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active ? AppColors.leaf : const Color(0x59000000),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: Colors.white, size: size * 0.5),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final HerbalPlant? plant;
  final ClassificationResult result;
  final File? photo;
  final VoidCallback? onDetail;

  const _ResultCard({
    required this.plant,
    required this.result,
    required this.photo,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    final p = plant;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: p == null
          ? Row(
              children: [
                const Icon(Icons.help_outline_rounded,
                    color: AppColors.amber, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tanaman ini belum dikenali. Dekatkan kamera ke satu daun atau buah, '
                    'pakai cahaya cukup dan latar polos.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                SizedBox(
                  width: 58,
                  height: 58,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: PlantThumb(plant: p, file: photo),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        p.latin,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: result.confidence.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: AppColors.mint,
                          color: AppColors.leaf,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: onDetail,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Detail'),
                ),
              ],
            ),
    );
  }
}
