import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every tap target on screen that is smaller than 48×48 dp or has no label,
/// one line each (Flutter's own guidelines stop at the first).
List<String> tapTargetProblems(WidgetTester tester, {double min = 48}) {
  final out = <String>[];
  final view = tester.view;
  final screen = Offset.zero & (view.physicalSize / view.devicePixelRatio);
  void visit(SemanticsNode node, Matrix4 parentTransform) {
    final transform = parentTransform.clone();
    if (node.transform != null) transform.multiply(node.transform!);
    final rect = MatrixUtils.transformRect(transform, node.rect);
    final data = node.getSemanticsData();
    final tappable = data.hasAction(SemanticsAction.tap) ||
        data.hasAction(SemanticsAction.longPress);
    // A target cut off by a scroll view's edge (half scrolled out of view)
    // reports only its visible sliver; it is judged where it is fully shown.
    final clip = node.parentPaintClipRect;
    final cutByClip = clip != null &&
        ((node.rect.bottom - clip.bottom).abs() < 0.5 ||
            (node.rect.top - clip.top).abs() < 0.5) &&
        node.rect.height < min - 0.01;
    if (tappable &&
        !cutByClip &&
        !node.isMergedIntoParent &&
        !node.isInvisible &&
        !data.flagsCollection.isHidden &&
        screen.contains(rect.topLeft) &&
        screen.contains(rect.bottomRight - const Offset(0.01, 0.01))) {
      final name = [data.label, data.tooltip, data.value]
          .firstWhere((s) => s.trim().isNotEmpty, orElse: () => '');
      final what = name.isEmpty ? '(no label)' : '"${name.replaceAll('\n', ' ')}"';
      if (rect.width < min - 0.01 || rect.height < min - 0.01) {
        out.add('$what is ${rect.width.toStringAsFixed(1)}×'
            '${rect.height.toStringAsFixed(1)}');
      }
      if (name.isEmpty) out.add('a tap target at $rect has no label');
    }
    node.visitChildren((c) {
      visit(c, transform);
      return true;
    });
  }

  final root = tester.binding.renderViews.first.owner?.semanticsOwner
      ?.rootSemanticsNode;
  if (root != null) visit(root, Matrix4.identity());
  return out;
}

/// The label or tooltip of every tap target on screen.
List<String> tapTargetLabels(WidgetTester tester) {
  final out = <String>[];
  void visit(SemanticsNode node) {
    final data = node.getSemanticsData();
    if (data.hasAction(SemanticsAction.tap) ||
        data.hasAction(SemanticsAction.longPress)) {
      for (final s in [data.label, data.tooltip]) {
        if (s.trim().isNotEmpty) out.add(s.trim());
      }
    }
    node.visitChildren((c) {
      visit(c);
      return true;
    });
  }

  final root = tester.binding.renderViews.first.owner?.semanticsOwner
      ?.rootSemanticsNode;
  if (root != null) visit(root);
  return out;
}
