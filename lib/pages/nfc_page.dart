import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nonghai/components/custom_appbar.dart';
import 'package:nonghai/components/custom_button.dart';

class NfcPage extends StatefulWidget {
  const NfcPage({super.key});

  @override
  State<NfcPage> createState() => _NfcPageState();
}

class _NfcPageState extends State<NfcPage> {
  ValueNotifier<dynamic> result = ValueNotifier(null);

  NdefMessage message = NdefMessage([
    NdefRecord.createUri(Uri.parse('test')),
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Scan NFC'),
      body: SafeArea(
          child: FutureBuilder(
              future: NfcManager.instance.isAvailable(),
              builder: (context, snapshot) {
                if (snapshot.data != true) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phonelink_erase_rounded,
                          size: 125,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 20),
                        Text('NFC is not available for this device',
                            style: Theme.of(context).textTheme.labelMedium),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.speaker_phone_rounded,
                          size: 125,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'HOLD Your Pet-Collar Tag at the back of your phone',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                            '*Please do not move or remove the tag before scanning is complete',
                            style: Theme.of(context).textTheme.labelMedium,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        CustomButton1(
                            onTap: _ndefWrite, text: 'Write to NFC Tag')
                      ],
                    ),
                  ),
                );
              })),
    );
  }

  void _ndefWrite() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);

      //check is NFC tag is writable
      if (ndef == null || !ndef.isWritable) {
        result.value = 'Tag is not ndef writable';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }

      try {
        await ndef.write(message);
        result.value = 'Success to "Ndef Write"';
        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }
}
