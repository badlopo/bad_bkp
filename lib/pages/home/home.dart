import 'package:bookkeeping/pages/dashboard/dashboard.dart';
import 'package:bookkeeping/pages/management/management.dart';
import 'package:bookkeeping/pages/setting/setting.dart';
import 'package:bookkeeping/pages/transaction/transaction.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      resizeToAvoidBottomInset: false,
      tabBar: CupertinoTabBar(
        iconSize: 24,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_pie),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_plaintext),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.cube),
            label: 'Management',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (_, index) => const [
        DashboardPage(),
        TransactionPage(),
        ManagementPage(),
        SettingPage(),
      ][index],
    );
  }
}
