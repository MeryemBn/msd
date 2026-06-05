import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:go_router/go_router.dart';

class TeleconsultCallScreen extends StatefulWidget {
  final String roomName;
  final String? jwt;
  final String displayName;
  final String? email;

  const TeleconsultCallScreen({
    super.key,
    required this.roomName,
    this.jwt,
    required this.displayName,
    this.email,
  });

  @override
  State<TeleconsultCallScreen> createState() => _TeleconsultCallScreenState();
}

class _TeleconsultCallScreenState extends State<TeleconsultCallScreen> {
  bool _isConferenceJoined = false;
  bool _isPopped = false;

  @override
  void initState() {
    super.initState();
    _joinMeeting();
  }

  void _safePop() {
    if (!mounted || _isPopped) return;
    _isPopped = true;
    if (context.canPop()) {
      context.pop();
    }
  }

  void _joinMeeting() async {
    var options = JitsiMeetConferenceOptions(
      // Utilisation d'un serveur Jitsi public alternatif sans restriction d'hôte (FFMUC)
      serverURL: "https://meet.ffmuc.net",
      room: widget.roomName,
      token: widget.jwt,
      configOverrides: {
        "startWithAudioMuted": false,
        "startWithVideoMuted": false,
        "prejoinPageEnabled": false,
        "lobbyModeEnabled": false,
        "disableLobby": true,
        "enableChat": true,
        "readOnlyChat": false,
        "enableNoModeratorModule": true, // Aide à débloquer le chat pour les non-modérateurs
      },
      featureFlags: {
        "unsecure-meeting-indicator.enabled": false,
        "ios.screensharing.enabled": true,
        "pip.enabled": true,
        "lobby-mode.enabled": false,
        "meeting-password.enabled": false,
        "chat.enabled": true,
      },
      userInfo: JitsiMeetUserInfo(
        displayName: widget.displayName,
        email: widget.email,
      ),
    );

    var listener = JitsiMeetEventListener(
      conferenceJoined: (url) {
        if (mounted) {
          setState(() {
            _isConferenceJoined = true;
          });
        }
      },
      conferenceTerminated: (url, error) {
        _safePop();
      },
      readyToClose: () {
        _safePop();
      },
    );

    var jitsiMeet = JitsiMeet();
    await jitsiMeet.join(options, listener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _isConferenceJoined
            ? const SizedBox.shrink()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    "Connexion à la téléconsultation...",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _safePop,
                    child: const Text(
                      "Annuler",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
