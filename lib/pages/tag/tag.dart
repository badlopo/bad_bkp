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

  List<Tag>? result;

  Future<void> getAllTags() async {
    final r = await BKPDatabase.instance.getTags(
      filter: filter,
      pageSize: null,
    );

    setState(() {
      result = r;
    });
  }

  void handleTagCreation() async {
    final controller = TextEditingController();

    final name = await showCupertinoDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Create tag'),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CupertinoTextField(
              controller: controller,
              autofocus: true,
              maxLength: BKPConstraints.tagNameMaxLength,
              clearButtonMode: OverlayVisibilityMode.editing,
              placeholder: 'Enter tag name',
              onSubmitted: (s) => Navigator.pop(context, s),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context, controller.text),
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

    getAllTags();
  }

  void handleDeletion(Tag tag) async {
    // todo: get number of entries associate with this tag
    final count = 14253;

    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Delete tag "${tag.name}"?'),
          content: Text(
              'There are $count transactions with this tag. Are you sure you want to delete it?'),
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
      await BKPDatabase.instance.deleteTag(tag.id);
    });

    await getAllTags();
  }

  void handleFilter(String s) async {
    filter = s;
    await getAllTags();
  }

  void handleResetFilter() async {
    controller.clear();
    filter = '';
    await getAllTags();
  }

  @override
  void initState() {
    super.initState();

    getAllTags();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final list = result;

    if (list == null) {
      return CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        child: LoadingIndicator(),
      );
    }

    if (list.isEmpty) {
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
                onRefresh: getAllTags,
                child: ListView(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in list)
                          CupertinoButton.tinted(
                            sizeStyle: CupertinoButtonSize.small,
                            onPressed: null,
                            onLongPress: () => handleDeletion(tag),
                            child: Text(tag.name),
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
