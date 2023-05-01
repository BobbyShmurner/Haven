import 'package:flutter/material.dart';

class Rating extends StatelessWidget {
  const Rating({super.key, required this.rating, this.amount});

  final double rating;
  final int? amount;

  List<InlineSpan> _generateStars() {
    var stars = <InlineSpan>[];
    for (var i in Iterable.generate(5)) {
      IconData iconData = Icons.star_rate_rounded;

      if (rating - i < 0.5) {
        iconData = Icons.star_border_rounded;
      } else if (rating - i < 1.0) {
        iconData = Icons.star_half_rounded;
      }

      stars.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: SizedBox(
            width: i != 4 ? 18 : null,
            child: Icon(
              iconData,
              color: Colors.yellow.shade800,
            ),
          ),
        ),
      );
    }

    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${rating.toStringAsPrecision(2)} / 5.0',
          ),
          ..._generateStars(),
          if (amount != null)
            TextSpan(
              text: '($amount)',
            )
        ],
      ),
    );
  }
}
