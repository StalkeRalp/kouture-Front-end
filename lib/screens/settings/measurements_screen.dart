import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../backend/mock_firebase.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});
  static const String routeName = '/measurements';

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen>
    with TickerProviderStateMixin {

  static const Color _rose      = Color(0xFFFF8C8C);
  static const Color _roseLt    = Color(0xFFFFF5F5);
  static const Color _roseMid   = Color(0xFFFFD6D6);
  static const Color _navy      = Color(0xFF0D0D26);
  static const Color _cream     = Color(0xFFFAFAF8);
  static const Color _border    = Color(0xFFEEECEF);
  static const Color _muted     = Color(0xFF8E91A6);

  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = true;

  final Map<int, List<String>> _steps = {
    0: ['Neck', 'Shoulder', 'Bust / Chest', 'Waist'],
    1: ['Hips', 'Arm Length', 'Biceps', 'Wrist'],
    2: ['Inseam', 'Thigh', 'Calf', 'Ankle'],
  };

  static const Set<String> _mandatoryFields = {
    'Shoulder', 'Bust / Chest', 'Waist', 'Hips', 'Arm Length', 'Inseam'
  };

  static const Map<String, String> _labels = {
    'Neck': 'Cou', 'Shoulder': 'Épaules', 'Bust / Chest': 'Poitrine',
    'Waist': 'Taille', 'Hips': 'Hanches', 'Arm Length': 'Bras',
    'Biceps': 'Biceps', 'Wrist': 'Poignet', 'Inseam': 'Entrejambe',
    'Thigh': 'Cuisse', 'Calf': 'Mollet', 'Ankle': 'Cheville',
  };

  static const Map<String, BodyZone> _bodyZones = {
    'Neck':         BodyZone(cx: .50, cy: .135, region: BodyRegion.torso),
    'Shoulder':     BodyZone(cx: .32, cy: .180, region: BodyRegion.torso),
    'Bust / Chest': BodyZone(cx: .50, cy: .240, region: BodyRegion.torso),
    'Waist':        BodyZone(cx: .50, cy: .315, region: BodyRegion.torso),
    'Hips':         BodyZone(cx: .50, cy: .395, region: BodyRegion.torso),
    'Arm Length':   BodyZone(cx: .76, cy: .280, region: BodyRegion.rightArm),
    'Biceps':       BodyZone(cx: .21, cy: .250, region: BodyRegion.leftArm),
    'Wrist':        BodyZone(cx: .80, cy: .365, region: BodyRegion.rightArm),
    'Inseam':       BodyZone(cx: .50, cy: .560, region: BodyRegion.legs),
    'Thigh':        BodyZone(cx: .39, cy: .480, region: BodyRegion.legs),
    'Calf':         BodyZone(cx: .37, cy: .660, region: BodyRegion.legs),
    'Ankle':        BodyZone(cx: .36, cy: .795, region: BodyRegion.legs),
  };

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _filled = {};
  final Map<String, AnimationController> _rippleControllers = {};

  final Map<BodyRegion, double> _regionFill = {
    BodyRegion.torso: 0, BodyRegion.leftArm: 0,
    BodyRegion.rightArm: 0, BodyRegion.legs: 0,
  };

  String? _floatingField;
  String? _floatingValue;
  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  late AnimationController _jumpController;
  late Animation<double> _jumpAnim;
  late AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadInitialData();
  }

  void _initAnimations() {
    _floatController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    );
    _floatAnim = CurvedAnimation(parent: _floatController, curve: Curves.easeOut);

    _jumpController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 750),
    );
    _jumpAnim = CurvedAnimation(parent: _jumpController, curve: Curves.elasticOut);

    _breathController = AnimationController(
      vsync: this, duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    for (final step in _steps.values) {
      for (final field in step) {
        _controllers[field] = TextEditingController();
        _filled[field] = false;

        _rippleControllers[field] = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 500),
        );
      }
    }
  }

  Future<void> _loadInitialData() async {
    final user = await MockFirebase().getUser('u1');
    final measurements = user?['measurements'] as Map<String, dynamic>? ?? {};

    measurements.forEach((key, value) {
      if (_controllers.containsKey(key)) {
        _controllers[key]!.text = value.toString();
        _filled[key] = value.toString().isNotEmpty;
        if (_filled[key]!) _updateRegionFill(key);
      }
    });

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    for (final c in _rippleControllers.values) c.dispose();
    _floatController.dispose();
    _jumpController.dispose();
    _breathController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onFieldChanged(String field, String value) {
    final hasValue = value.isNotEmpty && double.tryParse(value) != null;
    if (hasValue && !(_filled[field] ?? false)) {
      setState(() => _filled[field] = true);
      _rippleControllers[field]!.forward(from: 0);
      _floatingField = field;
      _floatingValue = value;
      _floatController.forward(from: 0);
      _updateRegionFill(field);
      _checkAllFilled();
    } else if (!hasValue && (_filled[field] ?? false)) {
      setState(() {
        _filled[field] = false;
        _updateRegionFillForRegion(_bodyZones[field]!.region);
      });
    }
  }

  void _checkAllFilled() {
    final allFilled = _filled.values.every((v) => v);
    if (allFilled) {
      _jumpController.forward(from: 0).then((_) => _jumpController.reverse());
    }
  }

  void _updateRegionFill(String changedField) {
    final region = _bodyZones[changedField]?.region;
    if (region == null) return;
    _updateRegionFillForRegion(region);
  }

  void _updateRegionFillForRegion(BodyRegion region) {
    final fieldsInRegion = _bodyZones.entries
        .where((e) => e.value.region == region)
        .map((e) => e.key)
        .toList();
    final filledCount = fieldsInRegion.where((f) => _filled[f] == true).length;
    setState(() {
      _regionFill[region] = filledCount / fieldsInRegion.length;
    });
  }

  Future<void> _saveAll() async {
    final updated = _controllers.map((k, c) => MapEntry(k, c.text));
    await MockFirebase().updateUser('u1', {'measurements': updated});
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Modifications enregistrées', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: _navy,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void _next() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(_currentStep,
          duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
    } else {
      _saveAll();
    }
  }

  void _prev() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(_currentStep,
          duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _cream,
        body: Center(child: CircularProgressIndicator(color: _rose.withOpacity(0.5), strokeWidth: 2.5)),
      );
    }

    return Scaffold(
      backgroundColor: _cream,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.42,
                  child: _buildAvatarContainer(),
                ),
                Expanded(child: _buildFormPanel()),
              ],
            ),
          ),
          _buildActionFooter(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: _navy, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('MESURES',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold,
              color: _navy, letterSpacing: 2)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _border.withOpacity(0.8)),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final titles = ['MORPHOLOGIE', 'EXTRÉMITÉS', 'JAMBES'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          Row(children: List.generate(3, (i) => Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 3,
              margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
              decoration: BoxDecoration(
                color: i <= _currentStep ? _rose : _border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ))),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titles[_currentStep], style: const TextStyle(fontSize: 10, color: _rose, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              Text('${_currentStep + 1}/3', style: TextStyle(fontSize: 10, color: _muted.withOpacity(0.8), fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContainer() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 8, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: _navy.withOpacity(0.03), blurRadius: 30, offset: const Offset(0, 15))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            ..._rippleControllers.values,
            _floatController,
            _jumpController,
            _breathController,
          ]),
          builder: (context, _) => CustomPaint(
            painter: MeasurementsPainter(
              filled: Map.from(_filled),
              regionFill: Map.from(_regionFill),
              rippleControllers: _rippleControllers,
              bodyZones: _bodyZones,
              activeFields: _steps[_currentStep]!,
              floatingField: _floatingField,
              floatingValue: _floatingValue,
              floatProgress: _floatAnim.value,
              jumpProgress: _jumpAnim.value,
              breathProgress: _breathController.value,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  Widget _buildFormPanel() {
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (_, index) {
        final fields = _steps[index]!;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(8, 0, 24, 24),
          itemCount: fields.length,
          itemBuilder: (_, i) => _buildMeasurementCard(fields[i]),
        );
      },
    );
  }

  Widget _buildMeasurementCard(String key) {
    final label = _labels[key] ?? key;
    final isFilled = _filled[key] ?? false;
    final isMandatory = _mandatoryFields.contains(key);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isFilled ? _rose.withOpacity(0.3) : _border, width: 1.5),
        boxShadow: isFilled ? [
          BoxShadow(color: _rose.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _navy)),
              if (isMandatory)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: _roseLt, borderRadius: BorderRadius.circular(4)),
                  child: const Text('REQUIS', style: TextStyle(fontSize: 8, color: _rose, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controllers[key],
            keyboardType: TextInputType.number,
            onChanged: (v) => _onFieldChanged(key, v),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _navy),
            decoration: InputDecoration(
              hintText: '0.0',
              hintStyle: TextStyle(color: _border, fontSize: 18),
              suffixText: 'cm',
              suffixStyle: TextStyle(fontSize: 12, color: _muted, fontWeight: FontWeight.bold),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            SizedBox(
              height: 56,
              width: 56,
              child: ElevatedButton(
                onPressed: _prev,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: _cream,
                  foregroundColor: _navy,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: _border)),
                ),
                child: const Icon(Icons.chevron_left, size: 28),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _rose,
                  elevation: 8,
                  shadowColor: _rose.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Text(
                  _currentStep == 2 ? 'ENREGISTRER' : 'CONTINUER',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum BodyRegion { torso, leftArm, rightArm, legs }

class BodyZone {
  final double cx, cy;
  final BodyRegion region;
  const BodyZone({required this.cx, required this.cy, required this.region});
}

class MeasurementsPainter extends CustomPainter {
  final Map<String, bool> filled;
  final Map<BodyRegion, double> regionFill;
  final Map<String, AnimationController> rippleControllers;
  final Map<String, BodyZone> bodyZones;
  final List<String> activeFields;
  final String? floatingField;
  final String? floatingValue;
  final double floatProgress;
  final double jumpProgress;
  final double breathProgress;

  static const Color mainSkin = Color(0xFFFDE8E0);
  static const Color accentRose = Color(0xFFFF8C8C);
  static const Color shadowSkin = Color(0xFFF1D1C5);
  static const Color darkText = Color(0xFF1E1E2C);

  const MeasurementsPainter({
    required this.filled, required this.regionFill,
    required this.rippleControllers, required this.bodyZones,
    required this.activeFields, this.floatingField,
    this.floatingValue, required this.floatProgress,
    required this.jumpProgress, required this.breathProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final jumpY = -40 * jumpProgress;
    canvas.translate(0, h * 0.05 + jumpY);
    _drawSilhouette(canvas, w, h);
    _drawPoints(canvas, w, h);
    if (floatingField != null && floatProgress > 0) _drawOverlay(canvas, w, h);
  }

  void _drawSilhouette(Canvas canvas, double w, double h) {
    final skinPaint = Paint()..color = mainSkin..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = shadowSkin..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final bp = 1.0 + (0.015 * breathProgress);

    canvas.drawOval(Rect.fromCenter(center: Offset(w*0.5, h*0.08), width: w*0.16, height: h*0.10), skinPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w*0.5, h*0.08), width: w*0.16, height: h*0.10), strokePaint);

    canvas.save();
    canvas.translate(w*0.5, h*0.25);
    canvas.scale(bp, bp);
    canvas.translate(-w*0.5, -h*0.25);
    final torsoPath = Path()
      ..moveTo(w*0.34, h*0.16)..lineTo(w*0.66, h*0.16)
      ..quadraticBezierTo(w*0.68, h*0.22, w*0.62, h*0.32)
      ..quadraticBezierTo(w*0.65, h*0.42, w*0.60, h*0.46)
      ..lineTo(w*0.40, h*0.46)
      ..quadraticBezierTo(w*0.35, h*0.42, w*0.38, h*0.32)
      ..quadraticBezierTo(w*0.32, h*0.22, w*0.34, h*0.16)..close();
    canvas.drawPath(torsoPath, Paint()..color = darkText);
    canvas.restore();

    final armRot = 0.04 * math.sin(breathProgress * math.pi);
    for (bool left in [true, false]) {
      canvas.save();
      canvas.translate(left ? w*0.34 : w*0.66, h*0.16);
      canvas.rotate(left ? armRot : -armRot);
      final arm = Path()
        ..moveTo(0,0)..lineTo(left ? -w*0.04 : w*0.04, h*0.02)
        ..lineTo(left ? -w*0.06 : w*0.06, h*0.26)
        ..lineTo(left ? -w*0.02 : w*0.02, h*0.26)..close();
      canvas.drawPath(arm, skinPaint);
      canvas.drawPath(arm, strokePaint);
      canvas.restore();
    }

    final legs = Path()
      ..moveTo(w*0.40, h*0.46)..lineTo(w*0.60, h*0.46)
      ..lineTo(w*0.66, h*0.82)..lineTo(w*0.54, h*0.82)
      ..lineTo(w*0.5, h*0.55)
      ..lineTo(w*0.46, h*0.82)..lineTo(w*0.34, h*0.82)..close();
    canvas.drawPath(legs, Paint()..color = darkText.withOpacity(0.95));
  }

  void _drawPoints(Canvas canvas, double w, double h) {
    for (final field in bodyZones.keys) {
      final zone = bodyZones[field]!;
      final cx = w * zone.cx;
      final cy = h * zone.cy;
      final isFilled = filled[field] ?? false;
      final isActive = activeFields.contains(field);
      if (isActive) {
        final pulse = 0.5 + 0.5 * math.sin(DateTime.now().millisecondsSinceEpoch / 500);
        canvas.drawCircle(Offset(cx, cy), 12 + 6 * pulse, Paint()..color = accentRose.withOpacity(0.2));
      }
      canvas.drawCircle(Offset(cx, cy), 6, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(cx, cy), 6, Paint()..color = accentRose..style = PaintingStyle.stroke..strokeWidth = 2);
      if (isFilled) canvas.drawCircle(Offset(cx, cy), 3.5, Paint()..color = accentRose);
    }
  }

  void _drawOverlay(Canvas canvas, double w, double h) {
    final zone = bodyZones[floatingField];
    if (zone == null) return;
    final cx = w * zone.cx;
    final cy = h * zone.cy;
    final t = floatProgress;
    canvas.save();
    canvas.translate(0, -50 * t);
    final paint = Paint()..color = darkText.withOpacity(1 - t);
    final tp = TextPainter(
      text: TextSpan(text: '$floatingValue cm', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy - 25), width: tp.width + 24, height: 32), const Radius.circular(12));
    canvas.drawRRect(rect, paint);
    tp.paint(canvas, Offset(cx - tp.width/2, cy - 25 - tp.height/2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MeasurementsPainter old) => true;
}