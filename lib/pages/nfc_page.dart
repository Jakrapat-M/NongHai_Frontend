import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nonghai/components/custom_appbar_to_home.dart';
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
      NdefRecord.createUri(Uri.parse('${dotenv.get('NFC_URL')}/tracking#${widget.petId}')),
    ]);
    print('NFC URL: ${dotenv.get('NFC_URL')}/tracking#${widget.petId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBarToHome(title: 'Scan NFC'),
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
          _showErrorDialog(context, 'Tag is not ndef writable');
        }
        return;
      }

      try {
        await ndef.write(message);
        result.value = 'Success to "Ndef Write"';
        NfcManager.instance.stopSession(); // Stop the session to prevent immediate reading

        if (mounted) {
          _showSuccessDialog(context, 'Write Success');
        }
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());

        if (mounted) {
          _showErrorDialog(context, 'Error please try again');
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

  // Method to show success dialog
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Center(child: Text(message, style: Theme.of(context).textTheme.headlineMedium)),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Center(
                  child: Text('OK', style: TextStyle(color: Colors.white, fontSize: 16))),
              onPressed: () {
                Navigator.of(context).popAndPushNamed('/');
              },
            ),
          ],
        );
      },
    );
  }

  // Method to show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Center(child: Text(message, style: Theme.of(context).textTheme.headlineMedium)),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Center(
                  child: Text('OK', style: TextStyle(color: Colors.white, fontSize: 16))),
              onPressed: () {
                Navigator.of(context).pop(); // Close the error dialog only
              },
            ),
          ],
        );
      },
    );
  }
}
