part of 'pie_chart.dart';

enum Position { left, right }

class PieChartSegment {
  PieChartSegment({
    required this.value,
    required this.textDirection,
    required this.label,
    required this.color,
    required this.degree,
    required this.startAngle,
    required this.endAngle,
    required this.midAngle,
    required this.center,
    required this.radius,
    required this.innerRadius,
  });

  /// Initial value for this segment.
  final double value;

  /// Label for this segment.
  final String label;

  /// [TextDirection] for this segment.
  final TextDirection textDirection;

  /// Color for this segment.
  final Color color;

  /// Degree for this segment.
  final double degree;

  /// Start angle for this segment.
  final double startAngle;

  /// End angle for this segment.
  final double endAngle;

  /// Middle angle for this segment.
  final double midAngle;

  /// Center position for this segment.
  final Offset center;

  /// Outer radius for this segment.
  final double radius;

  /// Inner radius for this segment.
  final double innerRadius;

  Position get labelPosition {
    return ((midAngle >= -90 && midAngle < 0) || (midAngle >= 0 && midAngle < 90) || midAngle >= 270)
        ? Position.right
        : Position.left;
  }

  @override
  String toString() {
    return 'PieChartSegment(value: $value, label: $label, '
        'color: $color, degree: $degree, startAngle: $startAngle, '
        'endAngle: $endAngle, midAngle: $midAngle, center: $center, '
        'radius: $radius)';
  }
}

extension PositionExt on Position {
  T when<T>({required T Function() left, required T Function() right}) {
    return this == Position.left ? left() : right();
  }
}
