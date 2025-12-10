import 'package:flutter/material.dart';

class RatingWidget extends StatefulWidget {
  final double rating;
  final bool readOnly;
  final Function(double)? onRatingChanged;
  final double size;

  const RatingWidget({
    Key? key,
    this.rating = 0.0,
    this.readOnly = true,
    this.onRatingChanged,
    this.size = 28,
  }) : super(key: key);

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  late double _currentRating;
  late double _hoverRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
    _hoverRating = 0;
  }

  @override
  void didUpdateWidget(RatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rating != widget.rating) {
      _currentRating = widget.rating;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final ratingValue = index + 1;
        final isHovered = _hoverRating > 0 && ratingValue <= _hoverRating;
        final isFilled = ratingValue <= _currentRating;

        return MouseRegion(
          onEnter: widget.readOnly
              ? null
              : (_) {
                  setState(() => _hoverRating = ratingValue.toDouble());
                },
          onExit: widget.readOnly
              ? null
              : (_) {
                  setState(() => _hoverRating = 0);
                },
          child: GestureDetector(
            onTap: widget.readOnly
                ? null
                : () {
                    setState(() => _currentRating = ratingValue.toDouble());
                    widget.onRatingChanged?.call(ratingValue.toDouble());
                  },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                isFilled || isHovered ? Icons.star : Icons.star_border,
                size: widget.size,
                color: isFilled || isHovered
                    ? Colors.amber
                    : Colors.grey[400],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// Widget pour afficher les statistiques de notation
class RatingStatsWidget extends StatelessWidget {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> distribution;

  const RatingStatsWidget({
    Key? key,
    required this.averageRating,
    required this.totalRatings,
    required this.distribution,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2d2d44) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Moyenne et total
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '/5',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalRatings ${totalRatings > 1 ? 'avis' : 'avis'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    RatingWidget(
                      rating: averageRating,
                      readOnly: true,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Distribution
          if (distribution.isNotEmpty) ...[
            Text(
              'Distribution',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 12),
            ...List.generate(5, (index) {
              final rating = 5 - index;
              final count = distribution[rating] ?? 0;
              final percentage = totalRatings > 0 ? (count / totalRatings) * 100 : 0.0;

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        '$rating★',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Stack(
                          children: [
                            if (percentage > 0)
                              Container(
                                width: (percentage / 100),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.amber, Colors.orange],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '$count',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
