import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

part 'chart_data.dart';
part 'chart_segment.dart';

class PieChart extends LeafRenderObjectWidget {
  const PieChart({
    super.key,
    required this.data,
    this.radius = 0.5,
    this.innerRadius = 0.0,
    this.textStyle = const TextStyle(),
  }) : assert(radius > 0 && radius < 1, 'radius must be in range 0 ~ 1');

  /// Data to render.
  final List<PieChartData> data;

  /// Chart radius in percent.
  final double radius;

  /// Chart inner radius in percent.
  final double innerRadius;

  /// Labels text style.
  final TextStyle textStyle;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderPieChart(
      data: data,
      radius: radius,
      innerRadius: innerRadius,
      textStyle: textStyle,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    (renderObject as _RenderPieChart)
      ..data = data
      ..radius = radius
      ..innerRadius = innerRadius
      ..textStyle = textStyle;
  }
}

class _RenderPieChart extends RenderBox with _GeometryMixin {
  _RenderPieChart({
    required List<PieChartData> data,
    required double radius,
    required double innerRadius,
    required TextStyle textStyle,
  })  : _data = data,
        _radius = radius,
        _innerRadius = innerRadius,
        _textStyle = textStyle;

  // margin applied around the labels
  static const margin = EdgeInsets.all(8);

  List<PieChartData> _data;
  List<PieChartData> get data => _data;
  set data(List<PieChartData> value) {
    if (listEquals(_data, value)) return;
    _data = value;
    markNeedsPaint();
  }

  double _radius;
  double get radius => _radius;
  set radius(double value) {
    if (_radius == value) return;
    _radius = value;
    markNeedsPaint();
  }

  double _innerRadius;
  double get innerRadius => _innerRadius;
  set innerRadius(double value) {
    if (_innerRadius == value) return;
    _innerRadius = value;
    markNeedsPaint();
  }

  TextStyle _textStyle;
  TextStyle get textStyle => _textStyle;
  set textStyle(TextStyle value) {
    if (_textStyle == value) return;
    _textStyle = value;
    markNeedsPaint();
  }

  // the chart area
  Rect get _area {
    return Rect.fromLTWH(margin.left, margin.top, size.width - margin.horizontal, size.height - margin.vertical);
  }

  List<PieChartSegment> get _segments {
    final segments = <PieChartSegment>[];

    // ignore: prefer_int_literals
    final sum = _data.fold(0.0, (double current, PieChartData data) => current + data.value.abs());
    final chartRadius = (math.min(_area.width, _area.height) * _radius) / 2;

    var startAngle = 0.0;
    double endAngle;
    for (final item in _data) {
      final degree = (item.value.abs() / sum) * 360;
      endAngle = startAngle + degree;

      final segment = PieChartSegment(
        value: item.value,
        label: item.label,
        textDirection: item.textDirection,
        color: item.color,
        degree: degree,
        startAngle: startAngle,
        midAngle: (startAngle + endAngle) / 2,
        endAngle: endAngle,
        center: _area.center,
        radius: chartRadius,
        innerRadius: chartRadius * innerRadius,
      );

      segments.add(segment);
      startAngle = endAngle;
    }

    return segments;
  }

 @override
  Size computeDryLayout(BoxConstraints constraints) {
    final desiredWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 300.0;
    final desiredHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : 300.0;
    return Size(desiredWidth, desiredHeight);
  }

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas
      ..save()
      ..translate(offset.dx, offset.dy);

    for (final segment in _segments) {
      _drawSegment(canvas, segment);
      _drawLabel(canvas, segment);
    }

    canvas.restore();
  }

  void _drawSegment(Canvas canvas, PieChartSegment segment) {
    final paint = Paint()..color = segment.color;

    final start = degreesToRadians(segment.startAngle);
    final end = degreesToRadians(segment.endAngle);
    final radian = degreesToRadians(segment.degree);

    final innerRadiusEndPoint = math.Point<double>(
      segment.innerRadius * math.cos(end) + segment.center.dx,
      segment.innerRadius * math.sin(end) + segment.center.dy,
    );

    final radiusStartPoint = math.Point<double>(
      segment.radius * math.cos(start) + segment.center.dx,
      segment.radius * math.sin(start) + segment.center.dy,
    );

    final path = Path()
      ..lineTo(radiusStartPoint.x, radiusStartPoint.y)
      ..arcTo(Rect.fromCircle(center: segment.center, radius: segment.radius), start, radian, true)
      ..lineTo(innerRadiusEndPoint.x, innerRadiusEndPoint.y)
      ..arcTo(Rect.fromCircle(center: segment.center, radius: segment.innerRadius), end, start - end, true)
      ..lineTo(radiusStartPoint.x, radiusStartPoint.y);

    canvas.drawPath(path, paint);
  }

  void _drawLabel(Canvas canvas, PieChartSegment segment) {
    final paint = Paint()
      ..color = segment.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final connectorPath = Path();

    // draw connectors
    final connectorLength = segment.radius * 0.10;
    final connectorStart = degreeToPoint(segment.midAngle, segment.radius, segment.center);
    final connectorEnd = degreeToPoint(segment.midAngle, segment.radius + connectorLength, segment.center);

    connectorPath
      ..moveTo(connectorStart.dx, connectorStart.dy)
      ..lineTo(connectorEnd.dx, connectorEnd.dy);

    segment.labelPosition.when(
      left: () => connectorPath.lineTo(connectorEnd.dx - 10, connectorEnd.dy),
      right: () => connectorPath.lineTo(connectorEnd.dx + 10, connectorEnd.dy),
    );

    canvas.drawPath(connectorPath, paint);

    // draw label
    final textPainter = TextPainter(
      text: TextSpan(text: segment.label, style: _textStyle),
      textDirection: segment.textDirection,
      textAlign: TextAlign.center,
      maxLines: 1,
    )..layout();

    final textSize = Size(textPainter.width, textPainter.height);

    final rect = segment.labelPosition.when(
      left: () => Rect.fromLTWH(
        connectorEnd.dx - 10 - margin.right - textSize.width - margin.left,
        connectorEnd.dy - (textSize.height / 2) - margin.top,
        textSize.width + margin.left + margin.right,
        textSize.height + margin.top + margin.bottom,
      ),
      right: () => Rect.fromLTWH(
        connectorEnd.dx + 10,
        connectorEnd.dy - (textSize.height / 2) - margin.top,
        textSize.width + margin.left + margin.right,
        textSize.height + margin.top + margin.bottom,
      ),
    );

    assert(
      _area.left < rect.left && _area.right > rect.right,
      'Label(${segment.label}) overflow the chart area.',
    );

    final labelLocation = Offset(
      segment.labelPosition.when(
        left: () => rect.right - margin.right - textSize.width,
        right: () => rect.left + margin.left,
      ),
      rect.top + rect.height / 2 - textSize.height / 2,
    );

    textPainter.paint(canvas, labelLocation);
    // canvas.drawRect(rect, paint);
  }
}

mixin _GeometryMixin {
  double degreesToRadians(num deg) => deg * (math.pi / 180);

  Offset degreeToPoint(num degree, num radius, Offset center) {
    final radian = degreesToRadians(degree);
    return Offset(center.dx + math.cos(radian) * radius, center.dy + math.sin(radian) * radius);
  }
}
