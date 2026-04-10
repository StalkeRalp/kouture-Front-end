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

  // Adjusted Coordinates for the new Rounded Avatar
  static const Map<String, BodyZone> _bodyZones = {
    'Neck':         BodyZone(cx: .50, cy: .140, region: BodyRegion.torso),
    'Shoulder':     BodyZone(cx: .35, cy: .190, region: BodyRegion.torso),
    'Bust / Chest': BodyZone(cx: .50, cy: .260, region: BodyRegion.torso),
    'Waist':        BodyZone(cx: .50, cy: .340, region: BodyRegion.torso),
    'Hips':         BodyZone(cx: .50, cy: .420, region: BodyRegion.torso),
    'Arm Length':   BodyZone(cx: .72, cy: .300, region: BodyRegion.rightArm),
    'Biceps':       BodyZone(cx: .28, cy: .280, region: BodyRegion.leftArm),
    'Wrist':        BodyZone(cx: .76, cy: .380, region: BodyRegion.rightArm),
    'Inseam':       BodyZone(cx: .50, cy: .580, region: BodyRegion.legs),
    'Thigh':        BodyZone(cx: .42, cy: .500, region: BodyRegion.legs),
    'Calf':         BodyZone(cx: .40, cy: .700, region: BodyRegion.legs),
    'Ankle':        BodyZone(cx: .38, cy: .820, region: BodyRegion.legs),
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
  late AnimationController _blinkController;

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
      vsync: this, duration: const Duration(milliseconds: 800),
    );
    _jumpAnim = CurvedAnimation(parent: _jumpController, curve: Curves.elasticOut);

    _breathController = AnimationController(
      vsync: this, duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _blinkController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 150),
    );
    // Timer for random blinking
    _startRandomBlink();

    for (final step in _steps.values) {
      for (final field in step) {
        _controllers[field] = TextEditingController();
        _filled[field] = false;

        _rippleControllers[field] = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 600),
        );
      }
    }
  }

  void _startRandomBlink() async {
    while (mounted) {
      await Future.delayed(Duration(seconds: 3 + math.Random().nextInt(4)));
      if (mounted) {
        await _blinkController.forward();
        await _blinkController.reverse();
      }
    }
  }

  Future<void> _loadInitialData() async {
    final user = await MockFirebase().getUser('u1');
    final measurements = user?['measurements'] as Map<String, dynamic>? ?? {};

    measurements.forEach((key, value) {
      if (_controllers.containsKey(key)) {
        _controllers[key]!.text = value.toString();
        final hasVal = value.toString().isNotEmpty;
        _filled[key] = hasVal;
        if (hasVal) _updateRegionFill(key);
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
    _blinkController.dispose();
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
      _checkStepCompletion();
    } else if (!hasValue && (_filled[field] ?? false)) {
      setState(() {
        _filled[field] = false;
        _updateRegionFillForRegion(_bodyZones[field]!.region);
      });
    }
  }

  void _checkStepCompletion() {
    final currentFields = _steps[_currentStep]!;
    final allFilled = currentFields.every((f) => _filled[f] == true);
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
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Mesures sauvegardées avec succès', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: _navy,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ));
    }
  }

  void _next() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(_currentStep,
          duration: const Duration(milliseconds: 800), curve: Curves.elasticOut);
    } else {
      _saveAll();
    }
  }

  void _prev() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(_currentStep,
          duration: const Duration(milliseconds: 800), curve: Curves.elasticOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _cream,
        body: Center(child: CircularProgressIndicator(color: _rose)),
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
                  width: MediaQuery.of(context).size.width * 0.45,
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
        icon: const Icon(Icons.close_rounded, color: _navy),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('MESURES',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w900,
              color: _navy, letterSpacing: 3)),
    );
  }

  Widget _buildStepIndicator() {
    final titles = ['MORPHOLOGIE', 'EXTRÉMITÉS', 'JAMBES'];
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titles[_currentStep], style: const TextStyle(fontSize: 10, color: _rose, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              Text('${_currentStep + 1}/3', style: const TextStyle(fontSize: 10, color: _muted, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: List.generate(3, (i) => Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 6,
              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
              decoration: BoxDecoration(
                color: i <= _currentStep ? _rose : _border.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ))),
        ],
      ),
    );
  }

  Widget _buildAvatarContainer() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 4, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: _navy.withOpacity(0.04), blurRadius: 40, offset: const Offset(0, 20))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            ..._rippleControllers.values,
            _floatController,
            _jumpController,
            _breathController,
            _blinkController,
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
              blinkProgress: _blinkController.value,
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
          padding: const EdgeInsets.fromLTRB(8, 16, 24, 32),
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
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isFilled ? _roseLt : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isFilled ? _rose : _border, width: 2),
        boxShadow: isFilled ? [
          BoxShadow(color: _rose.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))
        ] : [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _navy)),
              if (isMandatory) ...[
                const SizedBox(width: 8),
                const Icon(Icons.star, size: 8, color: _rose),
              ],
              const Spacer(),
              if (isFilled) const Icon(Icons.check_circle_rounded, size: 16, color: _rose),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controllers[key],
            keyboardType: TextInputType.number,
            onChanged: (v) => _onFieldChanged(key, v),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _navy),
            decoration: InputDecoration(
              hintText: '0.0',
              hintStyle: TextStyle(color: _border, fontSize: 22),
              suffixText: 'cm',
              suffixStyle: const TextStyle(fontSize: 12, color: _muted, fontWeight: FontWeight.bold),
              border: InputBorder.none,
              isCollapsed: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            SizedBox(
              height: 64,
              width: 64,
              child: IconButton(
                onPressed: _prev,
                icon: const Icon(Icons.arrow_back_rounded, color: _muted),
                style: IconButton.styleFrom(
                  backgroundColor: _cream,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: SizedBox(
              height: 64,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _rose,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: _rose.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  _currentStep == 2 ? 'TERMINER' : 'SUIVANT',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2),
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
  final double blinkProgress;

  static const Color skinColor = Color(0xFFFFDAB9);
  static const Color accentRose = Color(0xFFFF8C8C);
  static const Color darkNavy  = Color(0xFF0D0D26);

  const MeasurementsPainter({
    required this.filled, required this.regionFill,
    required this.rippleControllers, required this.bodyZones,
    required this.activeFields, this.floatingField,
    this.floatingValue, required this.floatProgress,
    required this.jumpProgress, required this.breathProgress,
    required this.blinkProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // Jump and Breath translations
    final jumpY = -60 * jumpProgress;
    final breathScale = 1.0 + (0.015 * math.sin(breathProgress * math.pi));
    
    canvas.save();
    canvas.translate(w * 0.5, h * 0.5 + jumpY);
    canvas.scale(breathScale, breathScale);
    canvas.translate(-w * 0.5, -h * 0.5);

    _drawFriendlyBody(canvas, w, h);
    _drawFriendlyFace(canvas, w, h);
    _drawMeasurementPoints(canvas, w, h);
    
    canvas.restore();

    if (floatingField != null && floatProgress > 0) _drawValuePop(canvas, w, h);
  }

  void _drawFriendlyBody(Canvas canvas, double w, double h) {
    final bodyPaint = Paint()..color = skinColor;
    final strokePaint = Paint()..color = darkNavy.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = 3;
    final shadowPaint = Paint()..color = darkNavy.withOpacity(0.05);

    // Torso (Rounded Bean Shape)
    final torsoRect = Rect.fromCenter(center: Offset(w*0.5, h*0.35), width: w*0.35, height: h*0.35);
    final torsoPath = Path()..addRRect(RRect.fromRectAndRadius(torsoRect, Radius.circular(w*0.15)));
    
    // Draw Torso with Gradient if progress is made
    final torsoFill = regionFill[BodyRegion.torso] ?? 0;
    if (torsoFill > 0) {
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [accentRose, accentRose.withOpacity(0.2)],
          stops: [torsoFill, torsoFill + 0.1],
        ).createShader(torsoRect);
      canvas.drawPath(torsoPath, fillPaint);
    } else {
      canvas.drawPath(torsoPath, bodyPaint);
    }
    canvas.drawPath(torsoPath, strokePaint);

    // Arms (Rounded Capsules)
    final leftArmFill = regionFill[BodyRegion.leftArm] ?? 0;
    final rightArmFill = regionFill[BodyRegion.rightArm] ?? 0;

    _drawLimb(canvas, Offset(w*0.3, h*0.25), Offset(w*0.2, h*0.45), leftArmFill);
    _drawLimb(canvas, Offset(w*0.7, h*0.25), Offset(w*0.8, h*0.45), rightArmFill);

    // Legs (Rounded Capsules)
    final legsFill = regionFill[BodyRegion.legs] ?? 0;
    _drawLimb(canvas, Offset(w*0.42, h*0.5), Offset(w*0.38, h*0.85), legsFill);
    _drawLimb(canvas, Offset(w*0.58, h*0.5), Offset(w*0.62, h*0.85), legsFill);
  }

  void _drawLimb(Canvas canvas, Offset start, Offset end, double fillProgress) {
    final limbPaint = Paint()..color = skinColor..strokeCap = StrokeCap.round..strokeWidth = 35;
    final strokePaint = Paint()..color = darkNavy.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = 35..strokeCap = StrokeCap.round;
    
    canvas.drawLine(start, end, strokePaint);
    canvas.drawLine(start, end, limbPaint);

    if (fillProgress > 0) {
      final fillPaint = Paint()
        ..color = accentRose.withOpacity(0.8)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 35;
      final fillEnd = Offset(
        start.dx + (end.dx - start.dx) * fillProgress,
        start.dy + (end.dy - start.dy) * fillProgress,
      );
      canvas.drawLine(start, fillEnd, fillPaint);
    }
  }

  void _drawFriendlyFace(Canvas canvas, double w, double h) {
    final facePaint = Paint()..color = darkNavy;
    final headRect = Rect.fromCenter(center: Offset(w*0.5, h*0.1), width: w*0.22, height: h*0.14);
    canvas.drawRRect(RRect.fromRectAndRadius(headRect, Radius.circular(w*0.08)), Paint()..color = skinColor);
    
    final eyeY = h * 0.1;
    final eyeSize = 6.0 * (1 - blinkProgress);
    
    // Eyes
    canvas.drawCircle(Offset(w*0.44, eyeY), eyeSize, facePaint);
    canvas.drawCircle(Offset(w*0.56, eyeY), eyeSize, facePaint);
    
    if (blinkProgress > 0.5) {
      final blinkPaint = Paint()..color = darkNavy..style = PaintingStyle.stroke..strokeWidth = 2;
      canvas.drawLine(Offset(w*0.42, eyeY), Offset(w*0.46, eyeY), blinkPaint);
      canvas.drawLine(Offset(w*0.54, eyeY), Offset(w*0.58, eyeY), blinkPaint);
    }

    // Smile
    final smilePath = Path()
      ..moveTo(w*0.47, h*0.13)
      ..quadraticBezierTo(w*0.5, h*0.15, w*0.53, h*0.13);
    canvas.drawPath(smilePath, Paint()..color = darkNavy..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round);
  }

  void _drawMeasurementPoints(Canvas canvas, double w, double h) {
    for (final field in bodyZones.keys) {
      final zone = bodyZones[field]!;
      final cx = w * zone.cx;
      final cy = h * zone.cy;
      final isFilled = filled[field] ?? false;
      final isActive = activeFields.contains(field);

      if (isActive) {
        final ripple = rippleControllers[field]?.value ?? 0;
        if (ripple > 0) {
          canvas.drawCircle(Offset(cx, cy), 15 + 30 * ripple, Paint()..color = accentRose.withOpacity(0.3 * (1 - ripple)));
        }
        final pulse = 0.5 + 0.5 * math.sin(DateTime.now().millisecondsSinceEpoch / 400);
        canvas.drawCircle(Offset(cx, cy), 10 + 4 * pulse, Paint()..color = accentRose.withOpacity(0.2));
      }

      final pointPaint = Paint()..color = isFilled ? accentRose : Colors.white;
      canvas.drawCircle(Offset(cx, cy), 6, pointPaint);
      canvas.drawCircle(Offset(cx, cy), 6, Paint()..color = isFilled ? Colors.white : accentRose..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  void _drawValuePop(Canvas canvas, double w, double h) {
    final zone = bodyZones[floatingField];
    if (zone == null) return;
    final cx = w * zone.cx;
    final cy = h * zone.cy;
    final t = floatProgress;
    
    canvas.save();
    canvas.translate(0, -60 * t);
    
    final paint = Paint()..color = darkNavy.withOpacity(1 - t);
    final tp = TextPainter(
      text: TextSpan(text: '$floatingValue cm', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();

    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 30), width: tp.width + 30, height: 40),
      const Radius.circular(20)
    );
    canvas.drawRRect(rrect, paint);
    tp.paint(canvas, Offset(cx - tp.width/2, cy - 30 - tp.height/2));
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MeasurementsPainter old) => true;
}