import 'dart:async';

import 'package:flutter/material.dart';

typedef TunnelIdentifier = Object;
typedef StopListen = void Function();
typedef TunnelEventHandler<EventType> = void Function(EventType event);

/// A simple `mpmc` implementation based on `StreamController.broadcast`.
///
/// NOTE:
///
/// This implementation is very crude!
/// No RC, No Lock ...
/// It's obviously unsafe across threads, even the implementation of [cleanup] within the same thread is fragile.
class Tunnel {
  /// name => stream controller
  static final _tunnels = <TunnelIdentifier, StreamController>{};

  /// Cleanup unused tunnels.
  static void cleanup() {
    for (final tunnel in _tunnels.entries) {
      if (!tunnel.value.hasListener) {
        tunnel.value.close();
        _tunnels.remove(tunnel.key);
      }
    }
  }

  /// Get all active tunnel names.
  ///
  /// NOTE: This will also trigger a cleanup.
  static Set<TunnelIdentifier> get activeTunnels {
    cleanup();
    return _tunnels.keys.toSet();
  }

  final TunnelIdentifier identifier;

  StreamController get _controller => _tunnels[identifier]!;

  const Tunnel._(this.identifier);

  /// Find a tunnel by custom name, create one if not exists.
  ///
  /// NOTE: custom name may conflict with name of pre-defined tunnel, use with caution.
  factory Tunnel(TunnelIdentifier identifier) {
    // Create a new tunnel if not exists
    if (!_tunnels.containsKey(identifier)) {
      _tunnels[identifier] = StreamController.broadcast();
    }

    return Tunnel._(identifier);
  }

  /// Subscribe to event of a specific type, return a function to cancel the subscription
  StopListen listen<T>(void Function(T) handler) {
    final sub = _controller.stream.listen((event) {
      if (event is T) handler(event);
    });

    // We need more than just returning `sub.cancel` since we need to do some cleanup work.
    return () {
      sub.cancel();

      // Cleanup if no more listeners on this tunnel.
      //
      // OPTIMIZE:
      // This may reduce performance if the tunnel is frequently used (created and destroyed).
      // If so, we can use a counter to reduce the frequency of cleanup.
      if (!_controller.hasListener) {
        // No more listeners, close the controller and remove the tunnel
        _controller.close();
        _tunnels.remove(identifier);
      }
    };
  }

  /// Close the tunnel and all listeners on this tunnel will be dropped.
  void close() {
    _controller.close();
    _tunnels.remove(identifier);
  }

  /// You can send any data through the tunnel, only subscribers of the same type will receive it.
  void send([Object? data]) {
    _controller.add(data);
  }
}

mixin SingleTunnelListenerMixin<T extends StatefulWidget, EventType>
    on State<T> {
  StopListen? _unlistenTunnel;

  /// The name of the tunnel to listen to.
  abstract final TunnelIdentifier tunnelName;

  /// Handler for tunnel events.
  void onTunnelEvent(EventType event);

  @override
  void initState() {
    super.initState();
    _unlistenTunnel = Tunnel(tunnelName).listen<EventType>((ev) {
      if (mounted) onTunnelEvent(ev);
    });
  }

  @override
  void dispose() {
    _unlistenTunnel?.call();
    super.dispose();
  }
}
