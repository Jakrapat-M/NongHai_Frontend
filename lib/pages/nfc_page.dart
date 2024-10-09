import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nonghai/components/custom_appbar.dart';
import 'package:nonghai/components/custom_button.dart';

class NfcPage extends StatefulWidget {
  final String petId;
  const NfcPage({super.key, required this.petId});

  @override
  State<NfcPage> createState() => _NfcPageState();
}

class _NfcPageState extends State<NfcPage> {
  ValueNotifier<dynamic> result = ValueNotifier(null);
  bool isWriting = false; // To control the progress indicator and button state
  late NdefMessage message;

  @override
  void initState() {
    super.initState();
    message = NdefMessage([
      NdefRecord.createUri(
          Uri.parse('https://webnonghai.ryyyyyy.com/tracking#${widget.petId}')),
    ]);
  }

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
                    Text(
                      'NFC is not available for this device',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
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
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    isWriting
                        ? const CircularProgressIndicator() // Show Circular Progress when writing
                        : CustomButton1(
                            onTap: _ndefWrite,
                            text: 'Write to NFC Tag',
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _ndefWrite() async {
    setState(() {
      isWriting = true; // Start progress indicator
    });

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);

      if (ndef == null || !ndef.isWritable) {
        result.value = 'Tag is not ndef writable';
        NfcManager.instance.stopSession(errorMessage: result.value);

        if (mounted) {
          setState(() {
            isWriting = false; // Stop progress indicator
          });
        }
        return;
      }

      try {
        await ndef.write(message);
        result.value = 'Success to "Ndef Write"';
        NfcManager.instance
            .stopSession(); // Stop the session to prevent immediate reading

        if (mounted) {
          _showDialog(context, 'Write Success');
        }
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());

        if (mounted) {
          _showDialog(context, 'Error: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            isWriting = false; // Stop progress indicator
          });
        }
      }
    });
  }
}

// Method to show success dialog
void _showDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(
            child: Text(message,
                style: Theme.of(context).textTheme.headlineMedium)),
        actions: [
          TextButton(
            child: Center(
                child:
                    Text('OK', style: Theme.of(context).textTheme.labelMedium)),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}
