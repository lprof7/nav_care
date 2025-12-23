int responsiveGridColumns(
  double width, {
  double horizontalPadding = 32,
  double crossAxisSpacing = 14,
  double targetTileWidth = 240,
  double rang = 40,
  int minColumns = 2,
  int maxColumns = 6,
}) {
  final available = width - horizontalPadding;
  if (available <= 0) return minColumns;

  final minTileWidth = (targetTileWidth - rang).clamp(120, 10000);
  final maxTileWidth = (targetTileWidth + rang).clamp(140, 12000);

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
