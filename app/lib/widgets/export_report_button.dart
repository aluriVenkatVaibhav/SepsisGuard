import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../services/app_state.dart';

class ExportReportButton extends StatelessWidget {
  final AppState appState;

  const ExportReportButton({super.key, required this.appState});

  Future<void> generateReport() async {
    final pdf = pw.Document();
    final v = appState.vitals;

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "SepsisGuard Clinical Report",
              style: pw.TextStyle(fontSize: 24),
            ),

            pw.SizedBox(height: 20),

            pw.Text("Patient Name: ${appState.selectedPatient.name}"),
            pw.Text("Patient ID: ${appState.selectedPatient.id}"),

            pw.SizedBox(height: 20),

            pw.Text("Heart Rate: ${v.heartRate} bpm"),
            pw.Text("Respiratory Rate: ${v.respiratoryRate} rpm"),
            pw.Text("Temperature: ${v.temperature} °C"),
            pw.Text("SpO2: ${v.spo2}%"),

            pw.SizedBox(height: 20),

            pw.Text("Sepsis Risk Score: ${appState.prediction.riskScore}"),
            pw.Text("Risk Stage: ${appState.prediction.stage}"),
            pw.Text("Sepsis Phase: ${appState.prediction.sepsisPhase}"),
            pw.Text("Model Confidence: ${appState.prediction.confidence}"),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.download),
        label: const Text("Export Clinical Report"),
        onPressed: generateReport,
      ),
    );
  }
}
