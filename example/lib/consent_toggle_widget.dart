import 'package:flutter/material.dart';
// import 'package:fullstory_flutter/fullstory_flutter.dart';

class ConsentToggleWidget extends StatefulWidget {
  const ConsentToggleWidget({super.key});

  @override
  State<ConsentToggleWidget> createState() => _ConsentToggleWidgetState();
}

class _ConsentToggleWidgetState extends State<ConsentToggleWidget> {
  // ignore: prefer_final_fields
  bool _consentStatus = false;
  // ignore: prefer_final_fields
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FullStory Consent Toggle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Consent Status: ${_consentStatus ? "Granted" : "Denied"}',
                    style: TextStyle(
                      fontSize: 16,
                      color: _consentStatus ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Switch(
                  value: _consentStatus,
                  onChanged: _isLoading
                      ? null
                      : (value) => _toggleConsent(value),
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.green;
                    }
                    return Colors.red;
                  }),
                  trackColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0x8000FF00); // green with 50% opacity
                    }
                    return const Color(0x80FF0000); // red with 50% opacity
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _toggleConsent(null),
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_consentStatus ? Icons.block : Icons.check_circle),
                label: Text(
                  _consentStatus ? 'Revoke Consent' : 'Grant Consent',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _consentStatus ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _consentStatus
                  ? 'FullStory is currently capturing data with user consent.'
                  : 'FullStory is not capturing data due to lack of consent.',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleConsent(bool? newValue) async {
    // TODO: MOCA-10303 - once fullstory_flutter 0.6.0 is available, uncomment this.
    // final consentValue = newValue ?? !_consentStatus;

    // setState(() {
    //   _isLoading = true;
    // });

    // try {
    //   // Call FS.consent with the new value
    //   FS.consent(consentValue);

    //   setState(() {
    //     _consentStatus = consentValue;
    //     _isLoading = false;
    //   });

    //   // Show a snackbar to confirm the action
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(
    //           consentValue
    //               ? 'Consent granted - FullStory will capture data'
    //               : 'Consent revoked - FullStory will stop capturing data',
    //         ),
    //         backgroundColor: consentValue ? Colors.green : Colors.red,
    //         duration: const Duration(seconds: 2),
    //       ),
    //     );
    //   }
    // } catch (e) {
    //   setState(() {
    //     _isLoading = false;
    //   });

    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Error updating consent: $e'),
    //         backgroundColor: Colors.red,
    //         duration: const Duration(seconds: 3),
    //       ),
    //     );
    //   }
    // }
  }
}
