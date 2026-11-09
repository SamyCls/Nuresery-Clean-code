import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '/models/enfant.dart';
import '/models/accompagnateur.dart';
import 'package:open_filex/open_filex.dart';

class PDFFillService {
  static Future<void> fillAndSaveChildForm(
    Enfant enfant,
    List<Accompagnateur> accompagnateurs,
  ) async {
    final ByteData imageData = await rootBundle.load(
      'assets/pdf/ficheenfant.png',
    );
    final bgImage = pw.MemoryImage(imageData.buffer.asUint8List());

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.SizedBox(
                width: PdfPageFormat.a4.width,
                height: PdfPageFormat.a4.height,
                child: pw.Image(bgImage, fit: pw.BoxFit.fill),
              ),

              // Child identity
              _buildTextOverlay(281, 211, enfant.nom, fontSize: 15),
              _buildTextOverlay(305, 235, enfant.prenom, fontSize: 15),
              _buildTextOverlay(
                375,
                260,
                enfant.dateNaissance ?? '',
                fontSize: 15,
              ),
              _buildTextOverlay(279, 285, enfant.sexe ?? '', fontSize: 15),
              _buildTextOverlay(307, 313, enfant.adresse ?? '', fontSize: 15),

              // Father's info
              _buildTextOverlay(182, 406, enfant.nomPrenomPere ?? ''),
              _buildTextOverlay(165, 428, enfant.telPere ?? ''),
              _buildTextOverlay(165, 448, enfant.professionPere ?? ''),

              // Mother's info
              _buildTextOverlay(404, 464, enfant.nomPrenomMere ?? ''),
              _buildTextOverlay(387, 484, enfant.telMere ?? ''),
              _buildTextOverlay(380, 504, enfant.professionMere ?? ''),

              // Family status
              _buildTextOverlay(300, 542, enfant.statutFamilial ?? ''),

              // Accompagnateur 1
              if (accompagnateurs.isNotEmpty) ...[
                _buildTextOverlay(215, 643, accompagnateurs[0].nomPrenom),
                _buildTextOverlay(197, 666, accompagnateurs[0].telephone),
                _buildTextOverlay(
                  155,
                  689,
                  accompagnateurs[0].cin,
                  fontSize: 11,
                ),
              ],

              // Accompagnateur 2
              if (accompagnateurs.length > 1) ...[
                _buildTextOverlay(392, 643, accompagnateurs[1].nomPrenom),
                _buildTextOverlay(375, 666, accompagnateurs[1].telephone),
                _buildTextOverlay(
                  330,
                  689,
                  accompagnateurs[1].cin,
                  fontSize: 11,
                ),
              ],
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputFile = File(
      '${directory.path}/fiche_enfant_${enfant.nom}_${enfant.prenom}_$timestamp.pdf',
    );

    final bytes = await pdf.save();
    await outputFile.writeAsBytes(bytes);
    await OpenFilex.open(outputFile.path);
  }

  static pw.Widget _buildTextOverlay(
    double left,
    double top,
    String text, {
    double fontSize = 12,
  }) {
    return pw.Positioned(
      left: left,
      top: top,
      child: pw.Text(text, style: pw.TextStyle(fontSize: fontSize)),
    );
  }
}
