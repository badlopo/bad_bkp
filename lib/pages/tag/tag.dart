import 'package:bookkeeping/components/indicator.dart';
import 'package:bookkeeping/components/refreshable.dart';
import 'package:bookkeeping/constants/constraint.dart';
import 'package:bookkeeping/constants/tunnel.dart';
import 'package:bookkeeping/db/database.dart';
import 'package:bookkeeping/utils/toast.dart';
import 'package:bookkeeping/utils/tunnel.dart';
import 'package:flutter/cupertino.dart';

class TagHomePage extends StatefulWidget {
  const TagHomePage({super.key});

  @override
  State<TagHomePage> createState() => _TagHomePageState();
}

class _TagHomePageState extends State<TagHomePage>
    with
        AutomaticKeepAliveClientMixin,
        SingleTunnelListenerMixin<TagHomePage, Symbol> {
  @override
  bool get wantKeepAlive => true;

  @override
  TunnelIdentifier get tunnelName => BKPTunnels.tag;

  @override
  void onTunnelEvent(Symbol event) {
    if (event == #create) handleTagCreation();
  }

  final TextEditingController controller = TextEditingController();
  String filter = '';

  List<TagWithCount>? tags;

  Future<void> getTags() async {
    final r = await BKPDatabase.instance.getTagsWithCount(filter);

    setState(() {
      tags = r;
    });
  }

  void handleTagCreation() async {
    final name = await showCupertinoDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String s = '';
        return CupertinoAlertDialog(
          title: Text('Create tag'),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CupertinoTextField(
              autofocus: true,
              maxLength: BKPConstraints.tagNameMaxLength,
              clearButtonMode: OverlayVisibilityMode.editing,
              placeholder: 'Enter tag name',
              onChanged: (v) => s = v,
              onSubmitted: (v) => Navigator.pop(context, v),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context, s),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (name == null) return;
    if (name.isEmpty) {
      ToastUtils.error('Tag name can not be empty!');
      return;
    }

    await ToastUtils.loadingWithTxn(() async {
      await BKPDatabase.instance.createTag(name);
    });

    getTags();
  }

  void handleDeletion(TagWithCount tag) async {
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Delete tag "${tag.tag.name}"?'),
          content: Text(
              'There are ${tag.count} transactions with this tag. Are you sure you want to delete it?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;

    await ToastUtils.loadingWithTxn(() async {
      await BKPDatabase.instance.deleteTag(tag.tag.id);
    });

    await getTags();
  }

  void handleFilter(String s) async {
    filter = s;
    await getTags();
  }

  void handleResetFilter() async {
    controller.clear();
    filter = '';
    await getTags();
  }

  @override
  void initState() {
    super.initState();

    getTags();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (tags == null) {
      return CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        child: LoadingIndicator(),
      );
    }

    if (tags!.isEmpty) {
      return CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        child: EmptyIndicator(
          hint: 'No data',
          footer: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: filter.isEmpty
                ? CupertinoButton.filled(
                    onPressed: handleTagCreation,
                    child: Text('Create'),
                  )
                : CupertinoButton.filled(
                    onPressed: handleResetFilter,
                    child: Text('Reset filter'),
                  ),
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: CupertinoSearchTextField(
                controller: controller,
                onSubmitted: handleFilter,
                onSuffixTap: handleResetFilter,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Long press on a tag to delete.',
                style: TextStyle(
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: BKPRefreshable(
                onRefresh: getTags,
                child: ListView(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in tags!)
                          CupertinoButton.tinted(
                            sizeStyle: CupertinoButtonSize.small,
                            onPressed: null,
                            onLongPress: () => handleDeletion(tag),
                            child: Text('${tag.tag.name} (${tag.count})'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
