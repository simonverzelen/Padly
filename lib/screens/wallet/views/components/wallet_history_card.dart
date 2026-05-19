import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';

class WalletHistoryCard extends StatelessWidget {
  const WalletHistoryCard({
    super.key,
    this.isReturn = false,
    required this.date,
    required this.amount,
  });

  final bool isReturn;
  final String date;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
            const BorderRadius.all(Radius.circular(defaultBorderRadious)),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        minLeadingWidth: 24,
        leading: SvgPicture.asset(
          isReturn ? "assets/icons/Return.svg" : "assets/icons/Product.svg",
          color: Theme.of(context).iconTheme.color,
          height: 24,
          width: 24,
        ),
        title: Text(isReturn ? "Return" : "Purchase"),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: defaultPadding / 4),
          child: Text(
            date,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium!.color),
          ),
        ),
        trailing: Text(
          isReturn
              ? "+ \$${amount.toStringAsFixed(2)}"
              : "- \$${amount.toStringAsFixed(2)}",
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: isReturn ? successColor : errorColor),
        ),
      ),
    );
  }
}
