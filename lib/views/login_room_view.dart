import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/sync/sync_interface.dart';
import '../core/theme.dart';

class LoginRoomView extends StatefulWidget {
  const LoginRoomView({super.key});

  @override
  State<LoginRoomView> createState() => _LoginRoomViewState();
}

class _LoginRoomViewState extends State<LoginRoomView> {
  final _roomController = TextEditingController(text: "DRGN1");
  final _nameController = TextEditingController(text: "Krag");
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _roomController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _enterAs(VttSyncService syncService, {required bool asGm}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    const constRoomCode = "DRGN1";
    final playerName = asGm ? "Game Master" : "Mappa Player";

    // Attempt to join the default campaign room
    bool success = await syncService.joinRoom(constRoomCode, playerName, joinAsGm: asGm);
    if (!success) {
      // If room doesn't exist, create it (GM creates, player also triggers creation if entering first)
      bool created = await syncService.createRoom(constRoomCode, "Game Master");
      if (created) {
        // If entering as Player/Mappa, join the newly initialized room
        if (!asGm) {
          await syncService.joinRoom(constRoomCode, playerName, joinAsGm: false);
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Errore durante l'inizializzazione del tavolo.";
        });
        return;
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final syncService = Provider.of<VttSyncService>(context);

    return Scaffold(
      backgroundColor: const Color(0xff120f0d),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xff1c1714),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xff8a1c1c), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dragonbane Gold/Red Logo Title
                Text(
                  "DRAGONBANE",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xffdfc48c),
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      const Shadow(
                        color: Color(0xff8a1c1c),
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      )
                    ]
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tavolo Virtuale Locale",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xff8e857b),
                    fontSize: 14,
                    letterSpacing: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xff4d3b30), thickness: 1),
                const SizedBox(height: 24),

                Text(
                  "Seleziona la modalità di accesso per avviare il VTT:",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: const Color(0xffd5cdbd), fontSize: 13),
                ),
                const SizedBox(height: 32),

                // Error Message
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: VttTheme.conditionExhausted, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Buttons
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Color(0xffdfc48c)))
                else ...[
                  // 1. Enter as Game Master (GM)
                  InkWell(
                    onTap: () => _enterAs(syncService, asGm: true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xff8a1c1c), // DragonRed accent
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xffdfc48c), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      ),
                      child: Column(
                        children: [
                          Text(
                            "ENTRA COME GM",
                            style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Visualizzazione completa per il Master (Gestione Token/Luoghi)",
                            style: TextStyle(color: Color(0xffe2c0b5), fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Enter as MAPPA (Player View)
                  InkWell(
                    onTap: () => _enterAs(syncService, asGm: false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xff2d5a27), // DemonGreen accent
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xffdfc48c), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      ),
                      child: Column(
                        children: [
                          Text(
                            "ENTRA COME MAPPA",
                            style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Visualizzazione pulita per i Giocatori (Solo elementi visibili)",
                            style: TextStyle(color: Color(0xffcad9b6), fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class BoxPadding {
  static const all24 = EdgeInsets.all(24);
  static const all16 = EdgeInsets.all(16);
  static EdgeInsets all(double v) => EdgeInsets.all(v);
}
