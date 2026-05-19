import 'dart:typed_data';
import 'dart:ui' as ui;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> captureWidget(dynamic key) async {
  final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3.0);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void downloadPng(Uint8List bytes, String filename) {
  final blob = html.Blob([bytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}

Future<void> buildAndDownloadPdf(
  List<Uint8List> fronts,
  List<Uint8List> backs, {
  bool landscape = false,
}) async {
  assert(fronts.length == backs.length);

  // Web: gerar PDF via `pdf.save()` pode travar o main thread (sem isolate).
  // Fallback: abre uma janela de impressão com layout paginado; o usuário salva como PDF.
  if (kIsWeb) {
    final opened = _openPrintWindow(fronts, backs, landscape: landscape);
    if (opened) return;
    // Popup bloqueado: cai no método antigo (pode ser mais lento, mas funciona).
    await _buildAndDownloadPdfUsingPdfPackage(fronts, backs, landscape: landscape);
    return;
  }

  await _buildAndDownloadPdfUsingPdfPackage(fronts, backs, landscape: landscape);
}

Future<void> _buildAndDownloadPdfUsingPdfPackage(
  List<Uint8List> fronts,
  List<Uint8List> backs, {
  required bool landscape,
}) async {
  const mm = PdfPageFormat.mm;
  const cardW = 63.5 * mm;
  const cardH = 88.9 * mm;
  const cardGap = 4.0 * mm;
  const pairGap = 6.0 * mm;
  const rowGap = 5.0 * mm;
  const mH = 10.0 * mm;
  const mV = 10.0 * mm;
  const oficioW = 216.0 * mm;
  const oficioH = 330.0 * mm;

  final pageW = landscape ? oficioH : oficioW;
  final pageH = landscape ? oficioW : oficioH;
  final pageFormat = PdfPageFormat(pageW, pageH, marginAll: 0);

  final usableW = pageW - mH * 2;
  final usableH = pageH - mV * 2;
  final pairW = cardW * 2 + cardGap;
  final pairsPerRow = landscape ? ((usableW + pairGap) / (pairW + pairGap)).floor() : 1;
  final rowsPerPage = ((usableH + rowGap) / (cardH + rowGap)).floor();
  final perPage = (pairsPerRow * rowsPerPage).clamp(1, 999);
  final totalRowW = pairW * pairsPerRow + pairGap * (pairsPerRow - 1);
  final leftPad = (usableW - totalRowW) / 2;

  final pdf = pw.Document();
  final n = fronts.length;

  for (int pageStart = 0; pageStart < n; pageStart += perPage) {
    final pageEnd = (pageStart + perPage).clamp(0, n);
    pdf.addPage(pw.Page(
      pageFormat: pageFormat,
      margin: pw.EdgeInsets.symmetric(horizontal: mH, vertical: mV),
      build: (ctx) {
        final rows = <pw.Widget>[];
        int idx = pageStart;
        for (int row = 0; row < rowsPerPage && idx < pageEnd; row++) {
          final cols = <pw.Widget>[];
          for (int col = 0; col < pairsPerRow && idx < pageEnd; col++) {
            if (col > 0) cols.add(pw.SizedBox(width: pairGap));
            cols.add(pw.Row(children: [
              pw.Container(
                width: cardW,
                height: cardH,
                child: pw.Image(pw.MemoryImage(fronts[idx]), fit: pw.BoxFit.contain),
              ),
              pw.SizedBox(width: cardGap),
              pw.Container(
                width: cardW,
                height: cardH,
                child: pw.Image(pw.MemoryImage(backs[idx]), fit: pw.BoxFit.contain),
              ),
            ]));
            idx++;
          }
          if (row > 0) rows.add(pw.SizedBox(height: rowGap));
          rows.add(pw.Row(children: [pw.SizedBox(width: leftPad), ...cols]));
        }
        return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: rows);
      },
    ));
  }

  final bytes = await pdf.save();
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', 'spell_cards.pdf')
    ..click();
  html.Url.revokeObjectUrl(url);
}

bool _openPrintWindow(
  List<Uint8List> fronts,
  List<Uint8List> backs, {
  required bool landscape,
}) {
  // Units in mm for CSS.
  const cardW = 63.5;
  const cardH = 88.9;
  const cardGap = 4.0;
  const pairGap = 6.0;
  const rowGap = 5.0;
  const mH = 10.0;
  const mV = 10.0;
  const oficioW = 216.0;
  const oficioH = 330.0;

  final pageW = landscape ? oficioH : oficioW;
  final pageH = landscape ? oficioW : oficioH;
  final usableW = pageW - mH * 2;
  final usableH = pageH - mV * 2;
  final pairW = cardW * 2 + cardGap;
  final pairsPerRow = landscape ? ((usableW + pairGap) / (pairW + pairGap)).floor() : 1;
  final rowsPerPage = ((usableH + rowGap) / (cardH + rowGap)).floor();
  final perPage = (pairsPerRow * rowsPerPage).clamp(1, 999);
  final totalRowW = pairW * pairsPerRow + pairGap * (pairsPerRow - 1);
  final leftPad = (usableW - totalRowW) / 2;

  final frontUrls = <String>[];
  final backUrls = <String>[];
  final allUrls = <String>[];

  for (final bytes in fronts) {
    final url = html.Url.createObjectUrlFromBlob(html.Blob([bytes], 'image/png'));
    frontUrls.add(url);
    allUrls.add(url);
  }
  for (final bytes in backs) {
    final url = html.Url.createObjectUrlFromBlob(html.Blob([bytes], 'image/png'));
    backUrls.add(url);
    allUrls.add(url);
  }

  final buffer = StringBuffer();
  buffer.writeln('<!doctype html>');
  buffer.writeln('<html><head><meta charset="utf-8">');
  buffer.writeln('<title>Export</title>');
  buffer.writeln('<style>');
  buffer.writeln('@page { size: ${pageW}mm ${pageH}mm; margin: 0; }');
  buffer.writeln('html, body { margin: 0; padding: 0; }');
  buffer.writeln('body { -webkit-print-color-adjust: exact; print-color-adjust: exact; }');
  buffer.writeln('.page { width: ${pageW}mm; height: ${pageH}mm; box-sizing: border-box; padding: ${mV}mm ${mH}mm; }');
  buffer.writeln('.page + .page { page-break-before: always; }');
  buffer
      .writeln('.row { display: flex; align-items: flex-start; padding-left: ${leftPad}mm; box-sizing: border-box; }');
  buffer.writeln('.row + .row { margin-top: ${rowGap}mm; }');
  buffer.writeln('.pair { display: flex; align-items: flex-start; }');
  buffer.writeln('.pair + .pair { margin-left: ${pairGap}mm; }');
  buffer.writeln('.card { width: ${cardW}mm; height: ${cardH}mm; object-fit: contain; display: block; }');
  buffer.writeln('.gap { width: ${cardGap}mm; }');
  buffer.writeln('</style></head><body>');

  final n = frontUrls.length;
  for (int pageStart = 0; pageStart < n; pageStart += perPage) {
    final pageEnd = (pageStart + perPage).clamp(0, n);
    buffer.writeln('<div class="page">');
    int idx = pageStart;
    for (int row = 0; row < rowsPerPage && idx < pageEnd; row++) {
      buffer.writeln('<div class="row">');
      for (int col = 0; col < pairsPerRow && idx < pageEnd; col++) {
        buffer.writeln('<div class="pair">');
        buffer.writeln('<img class="card" src="${frontUrls[idx]}">');
        buffer.writeln('<div class="gap"></div>');
        buffer.writeln('<img class="card" src="${backUrls[idx]}">');
        buffer.writeln('</div>');
        idx++;
      }
      buffer.writeln('</div>');
    }
    buffer.writeln('</div>');
  }

  // Revoga blobs ao imprimir/fechar.
  final urlsJs = allUrls.map((u) => '"$u"').join(',');
  buffer.writeln('<script>');
  buffer.writeln('const __urls = [$urlsJs];');
  buffer.writeln('function __revoke(){ try { __urls.forEach(u => URL.revokeObjectURL(u)); } catch(e) {} }');
  buffer.writeln('window.addEventListener("beforeunload", __revoke);');
  buffer.writeln(
      'window.onafterprint = () => { __revoke(); try { URL.revokeObjectURL(window.location.href); } catch(e) {} try { window.close(); } catch(e) {} };');
  buffer.writeln('setTimeout(() => { try { window.focus(); window.print(); } catch(e) {} }, 200);');
  buffer.writeln('</script>');

  buffer.writeln('</body></html>');

  final htmlUrl = html.Url.createObjectUrlFromBlob(html.Blob([buffer.toString()], 'text/html'));
  final dynamic opened = html.window.open(htmlUrl, '_blank');
  if (opened == null) {
    html.Url.revokeObjectUrl(htmlUrl);
    for (final u in allUrls) {
      html.Url.revokeObjectUrl(u);
    }
    return false;
  }

  // O próprio HTML revoga allUrls e fecha a janela após imprimir.
  return true;
}
