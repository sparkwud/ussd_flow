import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ussd_advanced/ussd_advanced.dart';

class UssdTestScreen extends StatefulWidget {
  const UssdTestScreen({super.key});

  @override
  State<UssdTestScreen> createState() => _UssdTestScreenState();
}

class _UssdTestScreenState extends State<UssdTestScreen> {
  static const String NORMAL_SESSION = "NORMAL_SESSION";
  static const String SINGLE_SESSION = "SINGLE_SESSION";
  static const String MULTIPLE_SESSION = "MULTIPLE_SESSION";

  bool _isRunning = false;
  String? _response;
  late FocusNode _focusNode;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
    // Automatically focus the input field on startup
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Function to handle USSD requests
  Future<void> _runUSSD({required String type}) async {
    PermissionStatus phonePermission = await Permission.phone.status;
    if (phonePermission.isDenied) {
      PermissionStatus requestStatus = await Permission.phone.request();
      if (requestStatus.isDenied) {
        setState(() {
          _response = "Enable phone permission and retry";
        });
        return;
      }
    }

    setState(() {
      _isRunning = true;
    });

    try {
      switch (type) {
        case NORMAL_SESSION:
          UssdAdvanced.sendUssd(code: _controller.text, subscriptionId: 1);
          break;
        case SINGLE_SESSION:
          String? singleSessionResponse = await UssdAdvanced.sendAdvancedUssd(
              code: _controller.text, subscriptionId: 1);
          setState(() {
            _response = singleSessionResponse;
          });
          break;
        case MULTIPLE_SESSION:
          String? multiSessionResponse = await UssdAdvanced.multisessionUssd(
              code: _controller.text, subscriptionId: 1);
          setState(() {
            _response = multiSessionResponse;
          });
          String? secondResponse = await UssdAdvanced.sendMessage('8');
          setState(() {
            _response = secondResponse;
          });
          await UssdAdvanced.cancelSession();
          break;
      }
    } catch (e) {
      setState(() {
        _response = "Error: $e";
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('USSD Test'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),

                // USSD Code Input
                TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'USSD Code',
                    hintText: 'Eg: *124#',
                    border: OutlineInputBorder(),
                  ),
                  onTapOutside: (_) => _focusNode.unfocus(),
                ),

                const SizedBox(height: 16),

                // Displaying the response
                if (_response != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(_response!, style: TextStyle(fontSize: 16)),
                  ),

                // Loading indicator or buttons based on the state
                if (_isRunning)
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  )
                else
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => _runUSSD(type: NORMAL_SESSION),
                        child: const Text('Normal Request'),
                      ),
                      ElevatedButton(
                        onPressed: () => _runUSSD(type: SINGLE_SESSION),
                        child: const Text('Single Session Request'),
                      ),
                      ElevatedButton(
                        onPressed: () => _runUSSD(type: MULTIPLE_SESSION),
                        child: const Text('Multi Session Request'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
