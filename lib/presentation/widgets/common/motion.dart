import 'dart:async';

import 'package:flutter/material.dart';

/// ظهور تدريجي مع انزلاق خفيف، يُستخدم لإظهار العناصر بشكل متتابع.
///
/// عند تمرير [playOnceKey] لا تُعاد الحركة لنفس العنصر عند إعادة بنائه
/// (مثل الرجوع لأعلى القائمة أو تبديل التبويبات).
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.08),
    this.duration = const Duration(milliseconds: 450),
    this.playOnceKey,
  });

  final Widget child;
  final Duration delay;
  final Offset offset;
  final Duration duration;
  final Object? playOnceKey;

  /// تأخير متدرج حسب ترتيب العنصر (بحد أقصى لتجنب البطء في القوائم الطويلة)
  static Duration stagger(int index, {int maxSteps = 8, int stepMs = 55}) {
    return Duration(milliseconds: (index.clamp(0, maxSteps)) * stepMs);
  }

  static final Set<Object> _played = <Object>{};

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final key = widget.playOnceKey;
    if (key != null) {
      if (FadeSlideIn._played.contains(key)) {
        _controller.value = 1;
        return;
      }
      FadeSlideIn._played.add(key);
    }
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: widget.offset,
          end: Offset.zero,
        ).animate(_curve),
        child: widget.child,
      ),
    );
  }
}

/// عدّاد يتحرك من القيمة القديمة إلى الجديدة
class CountUp extends StatelessWidget {
  const CountUp({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 700),
  });

  final int value;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text('$v', style: style),
    );
  }
}
