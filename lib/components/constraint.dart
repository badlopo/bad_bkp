import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModalFormConstraintWrapper extends StatelessWidget {
  final Widget child;

  const ModalFormConstraintWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height -
              MediaQuery.paddingOf(context).top -
              kMinInteractiveDimensionCupertino * 0.6,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(kRadialReactionRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}
