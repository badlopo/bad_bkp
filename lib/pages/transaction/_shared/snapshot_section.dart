import 'dart:io';

import 'package:bookkeeping/utils/image.dart';
import 'package:bookkeeping/utils/storage.dart';
import 'package:bookkeeping/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class _SnapshotItem extends StatelessWidget {
  final File file;
  final VoidCallback onDelete;

  const _SnapshotItem({required this.file, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            fullscreenDialog: true,
            builder: (context) => CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                // TODO: implement download functionality
                // trailing: CupertinoButton(
                //   sizeStyle: CupertinoButtonSize.small,
                //   padding: EdgeInsets.zero,
                //   child: Text('Download'),
                //   onPressed: () {},
                // ),
              ),
              child: Center(child: Image.file(file)),
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: 8, right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              border: Border.fromBorderSide(
                BorderSide(
                  color: CupertinoColors.systemFill,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.file(file),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onDelete,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: CupertinoColors.separator.resolveFrom(context),
                child: Icon(
                  CupertinoIcons.delete,
                  size: 16,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SnapshotSection extends StatefulWidget {
  final Set<File> files;

  const SnapshotSection({super.key, required this.files});

  @override
  State<StatefulWidget> createState() => _SnapshotSectionState();
}

class _SnapshotSectionState extends State<SnapshotSection> {
  void handleSnapshotSelection() async {
    final fromAlbum = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Snapshot'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, false),
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo_camera),
                Text('Take a photo'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, true),
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo),
                Text('Select from album'),
              ],
            ),
          ),
        ],
      ),
    );
    if (fromAlbum == null) return;

    final r = await (fromAlbum
        ? ImageUtils.getFromAlbum()
        : ImageUtils.getByCamera());

    if (r != null) {
      final newFile = await StorageUtils.saveTransactionSnapshot(r);
      if (widget.files.any((f) => f.path == newFile.path)) {
        ToastUtils.error('This file has been added');
        return;
      }

      setState(() {
        widget.files.add(newFile);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      dividerMargin: 0,
      additionalDividerMargin: 0,
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Snapshot'),
          CupertinoButton(
            padding: EdgeInsets.zero,
            sizeStyle: CupertinoButtonSize.small,
            onPressed: handleSnapshotSelection,
            child: Icon(CupertinoIcons.add),
          ),
        ],
      ),
      children: [
        if (widget.files.isNotEmpty)
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(12),
              children: [
                for (final file in widget.files)
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: _SnapshotItem(
                      file: file,
                      onDelete: () => setState(() {
                        widget.files.remove(file);
                      }),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
