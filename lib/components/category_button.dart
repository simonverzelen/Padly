import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:padly/constants.dart';

class CategoryButton extends StatelessWidget {
  const CategoryButton({
    super.key,
    required this.text,
    this.svgSrc,
    required this.isActive,
    required this.press,
    this.isDisabled = false,
  });

  final String text;
  final String? svgSrc;
  final bool isActive;
  final VoidCallback press;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : press,
      borderRadius:
          const BorderRadius.all(Radius.circular(defaultBorderRadious)),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1,
        child: Container(
          height: defaultPadding * 2,
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          decoration: BoxDecoration(
            color: isActive ? primaryColor : pillBackgroundColor,
            border:
                Border.all(color: isActive ? Colors.transparent : primaryColor),
            borderRadius:
                const BorderRadius.all(Radius.circular(defaultBorderRadious)),
          ),
          child: Wrap(
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: [
              if (svgSrc != null)
                SvgPicture.asset(
                  svgSrc!,
                  height: defaultPadding,
                  colorFilter: ColorFilter.mode(
                    isActive ? backgroundColor : whiteColor,
                    BlendMode.srcIn,
                  ),
                ),
              if (svgSrc != null) const SizedBox(width: defaultPadding / 2),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isActive ? backgroundColor : whiteColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
