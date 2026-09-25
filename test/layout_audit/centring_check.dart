import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Finds text that is meant to be centred but, once it wraps, has its lines
/// pushed to one side: a paragraph of two or more lines, aligned to the start,
/// in a column that centres its children and centres at least one other,
/// narrower child beside it (an icon, a button, a short line).
///
/// Returns one line per offender: the text (shortened) and its source line
/// when widget-creation tracking names it.
List<String> offCentreText(WidgetTester tester) {
  final out = <String>[];
  void visit(RenderObject o) {
    if (o is RenderParagraph && _offCentre(o)) {
      final text = o.text.toPlainText().replaceAll('\n', ' ');
      final where = RegExp(r'(lib/[^\s:]+:\d+)')
          .firstMatch(o.debugCreator?.toString() ?? '')
          ?.group(1);
      out.add('"${text.length > 40 ? '${text.substring(0, 40)}…' : text}"'
          '${where == null ? '' : ' [$where]'}');
    }
    o.visitChildren(visit);
  }

  visit(tester.binding.rootElement!.renderObject!);
  return out;
}

bool _offCentre(RenderParagraph p) {
  if (!p.hasSize || p.size.width < 1) return false;
  final align = p.textAlign;
  if (align == TextAlign.center || align == TextAlign.end ||
      align == TextAlign.right) {
    return false;
  }
  // Two lines or more (counted from line metrics: glyph boxes of mixed
  // fonts on one line have different tops).
  final painter = TextPainter(
    text: p.text,
    textDirection: p.textDirection,
    textScaler: p.textScaler,
    maxLines: p.maxLines,
    strutStyle: p.strutStyle,
    textWidthBasis: p.textWidthBasis,
    locale: p.locale,
  )..layout(maxWidth: p.size.width + 0.5);
  final lines = painter.computeLineMetrics().length;
  painter.dispose();
  if (lines < 2) return false;

  // The nearest column above it (through single-child wrappers).
  RenderObject child = p;
  var parent = p.parent;
  while (parent != null && parent is! RenderFlex) {
    if (parent is! RenderProxyBox && parent is! RenderShiftedBox) return false;
    child = parent;
    parent = parent.parent;
  }
  if (parent is! RenderFlex || parent.direction != Axis.vertical) return false;
  if (parent.crossAxisAlignment != CrossAxisAlignment.center) return false;
  // Another child of that column that is visibly centred (narrower than the
  // column): the column is laying things out on a centre line.
  final column = parent;
  var centredSibling = false;
  column.visitChildren((c) {
    if (identical(c, child) || c is! RenderBox || !c.hasSize) return;
    if (c.size.width > 0 && c.size.width < column.size.width - 8) {
      centredSibling = true;
    }
  });
  return centredSibling;
}
