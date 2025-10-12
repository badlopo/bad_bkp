import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UnDraw extends StatelessWidget {
  final String assetName;
  final double? width;
  final double? height;

  const UnDraw.noData({super.key, this.width, this.height})
      : assetName = 'assets/undraw/no_data.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      width: width,
      height: height,
      // colorFilter:
      //     color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      clipBehavior: Clip.antiAlias,
    );
  }
}
