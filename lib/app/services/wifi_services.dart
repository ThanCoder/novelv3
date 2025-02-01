import 'dart:io';

Future<String> getWifiAddress() async {
  String res = 'localhsot';

  try {
    // Network Interfaces ကို ရယူပါ
    List<NetworkInterface> interfaces = await NetworkInterface.list(
      includeLoopback: false, // Loopback address (e.g., 127.0.0.1) မပါအောင်
      type: InternetAddressType.IPv4, // IPv4 address only
    );

    // Linux နဲ့ Android မှာ WiFi နဲ့ပတ်သက်တဲ့ interface တွေကို filter လုပ်ရန်
    if (Platform.isLinux) {
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.address.isNotEmpty) {
            res = addr.address;
            break;
          }
        }
      }
    } else {
      for (var interface in interfaces) {
        if (_isWiFiInterface(interface.name)) {
          print('Interface Name: ${interface.name}');
          for (var address in interface.addresses) {
            print('WiFi Host Address: ${address.address}');
          }
        }
      }
    }
  } catch (e) {
    print('Error: $e');
  }
  return res;
}

// Helper function to check for WiFi-related interfaces
bool _isWiFiInterface(String interfaceName) {
  // Linux တွင် WiFi interface များသည် `wlan` သို့မဟုတ် `wifi` ပါသည်
  // Android တွင် WiFi interface များသည် `wlan` ပါသည်
  return interfaceName.contains('wlan') || interfaceName.contains('wifi');
}
