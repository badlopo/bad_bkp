import 'package:bookkeeping/components/undraw.dart';
import 'package:flutter/cupertino.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;

  const LoadingIndicator({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.threeRotatingDots(
        size: size,
        color: CupertinoTheme.of(context).primaryColor,
      ),
    );
  }
}

class EmptyIndicator extends StatelessWidget {
  final String? hint;
  final Widget? footer;

  const EmptyIndicator({super.key, this.hint, this.footer});

  @override
  Widget build(BuildContext context) {
    if (hint == null && footer == null) {
      return Center(child: UnDraw.noData(width: 128));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UnDraw.noData(width: 128),
        if (hint != null)
          Padding(
            padding: EdgeInsets.only(top: 24),
            child: Text(
              hint!,
              style: TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (footer != null)
          Padding(padding: EdgeInsets.only(top: 64), child: footer),
      ],
    );
  }
}
