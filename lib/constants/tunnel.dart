import 'package:bookkeeping/utils/tunnel.dart';

enum BKPTunnelName {
  /// custom tab 下的事件
  ///
  /// - `#category` 新建 category
  /// - `#tag` 新建 tag
  custom,

  /// 刷新列表
  ///
  /// - `#category`
  /// - `#tag`
  /// - `#transaction`
  refresh,
}

abstract class BKPTunnel {
  /// `BKPTunnelName.custom` 事件
  ///
  /// ---
  ///
  /// [to]
  /// - `#category`
  /// - `#tag`
  static void sendCustom(Symbol to) {
    assert(const {#category, #tag}.contains(to));
    Tunnel(BKPTunnelName.custom).send(to);
  }

  /// `BKPTunnelName.refresh` 事件
  ///
  /// ---
  ///
  /// [to]
  /// - `#category`
  /// - `#tag`
  /// - `#transaction`
  static void sendRefresh(Symbol to) {
    assert(const {#category, #tag, #transaction}.contains(to));
    Tunnel(BKPTunnelName.refresh).send(to);
  }
}
