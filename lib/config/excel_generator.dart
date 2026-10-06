import 'dart:convert';
import 'package:archive/archive.dart';

/// Helper to generate pure OpenXML Spreadsheet (.xlsx) files.
class ExcelGenerator {
  /// Encodes attendance data into standard .xlsx Excel bytes.
  static List<int> generateAttendanceWorkbook({
    required List<String> headers,
    required List<List<dynamic>> rows,
    String sheetName = 'Attendance',
  }) {
    final archive = Archive();

    // 1. [Content_Types].xml
    const contentTypesXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
  <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
</Types>''';
    _addFile(archive, '[Content_Types].xml', contentTypesXml);

    // 2. _rels/.rels
    const rootRelsXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
</Relationships>''';
    _addFile(archive, '_rels/.rels', rootRelsXml);

    // 3. xl/_rels/workbook.xml.rels
    const workbookRelsXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>''';
    _addFile(archive, 'xl/_rels/workbook.xml.rels', workbookRelsXml);

    // 4. xl/workbook.xml
    final escapedSheetName = _escapeXml(sheetName);
    final workbookXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheets>
    <sheet name="$escapedSheetName" sheetId="1" r:id="rId1"/>
  </sheets>
</workbook>''';
    _addFile(archive, 'xl/workbook.xml', workbookXml);

    // 5. xl/styles.xml
    const stylesXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <fonts count="2">
    <font><name val="Calibri"/><sz val="11"/><color rgb="FF000000"/></font>
    <font><b/><name val="Calibri"/><sz val="11"/><color rgb="FFFFFFFF"/></font>
  </fonts>
  <fills count="3">
    <fill><patternFill patternType="none"/></fill>
    <fill><patternFill patternType="gray125"/></fill>
    <fill><patternFill patternType="solid"><fgColor rgb="FF1E3A8A"/></patternFill></fill>
  </fills>
  <borders count="2">
    <border><left/><right/><top/><bottom/><diagonal/></border>
    <border>
      <left style="thin"><color rgb="FFD1D5DB"/></left>
      <right style="thin"><color rgb="FFD1D5DB"/></right>
      <top style="thin"><color rgb="FFD1D5DB"/></top>
      <bottom style="thin"><color rgb="FFD1D5DB"/></bottom>
    </border>
  </borders>
  <cellStyleXfs count="1">
    <xf numFmtId="0" fontId="0" fillId="0" borderId="0"/>
  </cellStyleXfs>
  <cellXfs count="2">
    <xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyBorder="1"/>
    <xf numFmtId="0" fontId="1" fillId="2" borderId="1" xfId="0" applyFont="1" applyFill="1" applyBorder="1"/>
  </cellXfs>
</styleSheet>''';
    _addFile(archive, 'xl/styles.xml', stylesXml);

    // 6. xl/worksheets/sheet1.xml
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    buffer.writeln(
        '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">');
    buffer.writeln('  <sheetData>');

    // Row 1: Headers (style s="1")
    buffer.writeln('    <row r="1">');
    for (int col = 0; col < headers.length; col++) {
      final colRef = _getColumnRef(col);
      final cellRef = '${colRef}1';
      final val = _escapeXml(headers[col]);
      buffer.writeln(
          '      <c r="$cellRef" t="inlineStr" s="1"><is><t>$val</t></is></c>');
    }
    buffer.writeln('    </row>');

    // Subsequent Rows: Data (style s="0")
    for (int r = 0; r < rows.length; r++) {
      final rowNum = r + 2;
      final row = rows[r];
      buffer.writeln('    <row r="$rowNum">');
      for (int c = 0; c < row.length; c++) {
        final colRef = _getColumnRef(c);
        final cellRef = '$colRef$rowNum';
        final val = row[c];

        if (val is num) {
          buffer.writeln('      <c r="$cellRef" s="0"><v>$val</v></c>');
        } else {
          final strVal = _escapeXml(val?.toString() ?? '');
          buffer.writeln(
              '      <c r="$cellRef" t="inlineStr" s="0"><is><t>$strVal</t></is></c>');
        }
      }
      buffer.writeln('    </row>');
    }

    buffer.writeln('  </sheetData>');
    buffer.writeln('</worksheet>');

    _addFile(archive, 'xl/worksheets/sheet1.xml', buffer.toString());

    final encoded = ZipEncoder().encode(archive);
    return encoded;
  }

  static void _addFile(Archive archive, String filename, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(filename, bytes.length, bytes));
  }

  static String _getColumnRef(int colIndex) {
    String ref = '';
    int index = colIndex;
    while (index >= 0) {
      ref = String.fromCharCode((index % 26) + 65) + ref;
      index = (index ~/ 26) - 1;
    }
    return ref;
  }

  static String _escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
