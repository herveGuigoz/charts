part of 'pie_chart.dart';

@immutable
class PieChartData {
  const PieChartData({
    required this.value,
    required this.label,
    required this.color,
    this.textDirection = TextDirection.ltr,
  });

  final double value;

  final String label;

  final Color color;

  final TextDirection textDirection;

  @override
  bool operator ==(covariant PieChartData other) {
    if (identical(this, other)) return true;

    return other.value == value && other.label == label && other.color == color && other.textDirection == textDirection;
  }

  @override
  int get hashCode {
    return value.hashCode ^ label.hashCode ^ color.hashCode ^ textDirection.hashCode;
  }
}
