import 'package:bookkeeping/components/indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TagHomePage extends StatefulWidget {
  const TagHomePage({super.key});

  @override
  State<TagHomePage> createState() => _TagHomePageState();
}

class _TagHomePageState extends State<TagHomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: LoadingIndicator(),
    );
  }
}
