import 'package:bookkeeping/pages/customs/category/category.dart';
import 'package:bookkeeping/pages/customs/tag/tag.dart';
import 'package:flutter/cupertino.dart';

const _animateDuration = Duration(milliseconds: 150);

class _CustomsPageTabBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final List<String> children;

  const _CustomsPageTabBar({
    required this.index,
    required this.onTap,
    required this.children,
  });

  Iterable<Widget> _items() sync* {
    for (final (index, label) in children.indexed) {
      final active = index == this.index;

      yield SizedBox(
        height: 32,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedDefaultTextStyle(
              duration: _animateDuration,
              style: active
                  ? TextStyle(
                      fontSize: 24,
                      color: CupertinoColors.label,
                      fontWeight: FontWeight.w500,
                    )
                  : TextStyle(
                      fontSize: 18,
                      color: CupertinoColors.secondaryLabel,
                      fontWeight: FontWeight.w400,
                    ),
              child: Text(label),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(spacing: 12, children: [..._items()]);
  }
}

class CustomsPage extends StatefulWidget {
  const CustomsPage({super.key});

  @override
  State<CustomsPage> createState() => _CustomsPageState();
}

class _CustomsPageState extends State<CustomsPage> {
  final PageController controller = PageController();
  int tabIndex = 0;

  void handleTabSwitch(int v) {
    if (v == tabIndex) return;

    setState(() {
      tabIndex = v;
    });
    controller.animateToPage(
      v,
      duration: _animateDuration,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        leading: _CustomsPageTabBar(
          index: tabIndex,
          onTap: handleTabSwitch,
          children: ['Category', 'Tag'],
        ),
      ),
      child: SafeArea(
        child: PageView(
          controller: controller,
          physics: ClampingScrollPhysics(),
          onPageChanged: (v) => setState(() {
            tabIndex = v;
          }),
          children: [CategoryHomePage(), TagHomePage()],
        ),
      ),
    );
  }
}
