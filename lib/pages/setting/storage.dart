import 'package:bookkeeping/utils/storage.dart';
import 'package:bookkeeping/utils/toast.dart';
import 'package:flutter/cupertino.dart';

const _bytePerKB = 1024;
const _bytePerMB = 1024 * 1024;
const _bytePerGB = 1024 * 1024 * 1024;

String _formatAsByte(int inByte) {
  return switch (inByte) {
    < 0 => '??',
    0 => '0',
    < _bytePerKB => '$inByte Byte',
    < _bytePerMB => '${(inByte / _bytePerKB).toStringAsFixed(2)} KB',
    < _bytePerGB => '${(inByte / _bytePerMB).toStringAsFixed(2)} MB',
    _ => '${(inByte / _bytePerGB).toStringAsFixed(2)} GB',
  };
}

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  int hive = 0;
  int drift = 0;
  int transactionSnapshot = 0;

  Future<void> getStorageUsage() async {
    await ToastUtils.loadingWithTxn(() async {
      hive = await StorageUtils.getSizeOfStorageInBytes(StorageType.hive);
      drift = await StorageUtils.getSizeOfStorageInBytes(StorageType.drift);
      transactionSnapshot = await StorageUtils.getSizeOfStorageInBytes(
          StorageType.transactionSnapshot);
    });

    setState(() {});
  }

  Future<void> cleanUnusedSnapshot() async {
    // TODO
    // 1. 检测
    // 2. 确认
    // 3. 清理
    // 4. 刷新
  }

  @override
  void initState() {
    super.initState();

    getStorageUsage();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Storage'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          sizeStyle: CupertinoButtonSize.small,
          onPressed: cleanUnusedSnapshot,
          child: Text('Clean'),
        ),
      ),
      child: ListView(
        physics: ClampingScrollPhysics(),
        children: [
          CupertinoListSection.insetGrouped(
            children: [
              CupertinoListTile(
                leading: Icon(CupertinoIcons.link),
                title: Text('Preferences'),
                subtitle: Text('Theme, brightness, etc.'),
                additionalInfo: Text(_formatAsByte(hive)),
              ),
              CupertinoListTile(
                leading: Icon(CupertinoIcons.tray_2),
                title: Text('Database'),
                subtitle: Text('Categories, tags, transactions, etc.'),
                additionalInfo: Text(_formatAsByte(drift)),
              ),
              CupertinoListTile(
                leading: Icon(CupertinoIcons.photo_on_rectangle),
                title: Text('Snapshot'),
                subtitle: Text('Image snapshots of all transactions.'),
                additionalInfo: Text(_formatAsByte(transactionSnapshot)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
