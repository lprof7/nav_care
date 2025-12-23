int responsiveGridColumns(
  double width, {
  double horizontalPadding = 32,
  double crossAxisSpacing = 14,
  double minTileWidth = 90,
  double maxTileWidth = 280,
  int minColumns = 2,
  int maxColumns = 6,
}) {
  final available = width - horizontalPadding;
  if (available <= 0) return minColumns;

  final maxByMinWidth =
      ((available + crossAxisSpacing) / (minTileWidth + crossAxisSpacing))
          .floor();
  final minByMaxWidth =
      ((available + crossAxisSpacing) / (maxTileWidth + crossAxisSpacing))
          .ceil();

  var columns = maxByMinWidth;
  if (columns < minByMaxWidth) {
    columns = minByMaxWidth;
  }

  if (columns < minColumns) return minColumns;
  if (columns > maxColumns) return maxColumns;
  return columns;
}
