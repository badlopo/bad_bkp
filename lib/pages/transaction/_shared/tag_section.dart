import 'package:bookkeeping/components/indicator.dart';
import 'package:bookkeeping/constants/constraint.dart';
import 'package:bookkeeping/db/database.dart';
import 'package:bookkeeping/utils/toast.dart';
import 'package:flutter/cupertino.dart';

class TagSection extends StatefulWidget {
  final Set<int> selectIds;

  const TagSection({super.key, required this.selectIds});

  @override
  State<TagSection> createState() => _TagSectionState();
}

class _TagSectionState extends State<TagSection> {
  final TextEditingController controller = TextEditingController();
  String filter = '';
  List<Tag>? tags;

  Future<void> getTags() async {
    final r = await BKPDatabase.instance.getTags(filter);

    setState(() {
      tags = r;
    });
  }

  Future<void> handleCreateTag() async {
    String name = filter;
    if (name.isEmpty) {
      final newName = await showCupertinoDialog<String>(
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
      if (newName == null) return;
      if (newName.isEmpty) {
        ToastUtils.error('Tag name can not be empty!');
        return;
      }
      name = newName;
    }

    setState(() {
      tags = null;
    });

    final newTag = await BKPDatabase.instance.createTag(name);
    widget.selectIds.add(newTag.id);

    return handleResetFilter();
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

  Iterable<Widget> _items() sync* {
    for (final tag in tags!) {
      final active = widget.selectIds.contains(tag.id);

      yield CupertinoButton.tinted(
        sizeStyle: CupertinoButtonSize.small,
        pressedOpacity: null,
        color: active ? null : CupertinoColors.tertiarySystemFill,
        // onPressed: null,
        onPressed: () {
          setState(() {
            active
                ? widget.selectIds.remove(tag.id)
                : widget.selectIds.add(tag.id);
          });
        },
        child: Text(
          tag.name,
          style: TextStyle(
            color: active
                ? null
                : CupertinoColors.tertiaryLabel.resolveFrom(context),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Tags'),
          CupertinoButton(
            padding: EdgeInsets.zero,
            sizeStyle: CupertinoButtonSize.small,
            onPressed: getTags,
            child: Icon(CupertinoIcons.arrow_2_circlepath),
          ),
        ],
      ),
      footer: Text(
        'Click a label to toggle its selection.',
        style: TextStyle(
          color: CupertinoColors.tertiaryLabel.resolveFrom(context),
          fontSize: 14,
        ),
      ),
      dividerMargin: 0,
      additionalDividerMargin: 0,
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: CupertinoSearchTextField(
            controller: controller,
            onChanged: (s) {
              if (s.length > BKPConstraints.tagNameMaxLength) {
                controller.text =
                    s.substring(0, BKPConstraints.tagNameMaxLength);
              }
            },
            onSubmitted: handleFilter,
            onSuffixTap: handleResetFilter,
          ),
        ),
        if (tags == null)
          SizedBox(height: 108, child: LoadingIndicator())
        else
          Padding(
            padding: EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              height: 88,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (tags!.isEmpty)
                      CupertinoButton.tinted(
                        sizeStyle: CupertinoButtonSize.small,
                        onPressed: handleCreateTag,
                        child: Text(filter.isEmpty
                            ? 'Create a tag'
                            : 'Create tag "$filter"'),
                      )
                    else
                      ..._items(),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
