#include "VLLayout.h"
#include <math.h>

VLLayout VLDefaultLayout(void) { return (VLLayout){0}; }
bool VLLayoutValid(VLLayout s) {
    return ((s.rows == 0 && s.columns == 0) ||
            (s.rows >= 2 && s.rows <= 10 && s.columns >= 2 && s.columns <= 8)) &&
        isfinite(s.horizontalSpacing) && s.horizontalSpacing >= 0 && s.horizontalSpacing <= 16 &&
        isfinite(s.verticalSpacing) && s.verticalSpacing >= 0 && s.verticalSpacing <= 16 &&
        isfinite(s.x) && fabs(s.x) <= 0.15 && isfinite(s.y) && fabs(s.y) <= 0.15;
}
bool VLCanFit(unsigned rows, unsigned columns, size_t count, bool widgets) {
    return rows >= 2 && rows <= 10 && columns >= 2 && columns <= 8 &&
           !widgets && count <= (size_t)rows * columns;
}
bool VLBegin(VLSession *s) {
    if (!s || s->editing) return false;
    s->snapshot = s->saved; s->working = s->saved; s->editing = true;
    return true;
}
bool VLPreview(VLSession *s, VLLayout layout) {
    if (!s || !s->editing || !VLLayoutValid(layout)) return false;
    s->working = layout; return true;
}
void VLCancel(VLSession *s) {
    if (!s || !s->editing) return;
    s->working = s->snapshot; s->editing = false;
}
bool VLCommit(VLSession *s, bool persisted) {
    if (!s || !s->editing || !persisted) return false;
    s->saved = s->working; s->editing = false; return true;
}
VLLayout VLCurrent(const VLSession *s) { return s->editing ? s->working : s->saved; }
VLLayout VLFittedLayout(VLLayout s, unsigned rows, unsigned columns,
                       double firstX, double firstY, double lastX, double lastY,
                       double width, double height) {
    /* Fit the entire grid together, never clamp individual icons into overlap. */
    if (columns > 1) s.horizontalSpacing = fmin(s.horizontalSpacing, fmax(0, (width - 60 - (lastX - firstX)) / (columns - 1)));
    if (rows > 1) s.verticalSpacing = fmin(s.verticalSpacing, fmax(0, (height - 76 - (lastY - firstY)) / (rows - 1)));
    double left = firstX - (columns - 1) * s.horizontalSpacing / 2;
    double right = lastX + (columns - 1) * s.horizontalSpacing / 2 + 60;
    double top = firstY - (rows - 1) * s.verticalSpacing / 2;
    double bottom = lastY + (rows - 1) * s.verticalSpacing / 2 + 76;
    s.x = fmax(-left, fmin(width - right, s.x * width)) / fmax(1, width);
    s.y = fmax(-top, fmin(height - bottom, s.y * height)) / fmax(1, height);
    return s;
}
void VLAdjustedOrigin(VLLayout s, unsigned rows, unsigned columns, long row, long column,
                      double width, double height, double *x, double *y) {
    /* SpringBoard coordinates are one-based. Center expansion around the grid. */
    *x += s.x * width + ((double)column - 1 - (columns - 1) / 2.0) * s.horizontalSpacing;
    *y += s.y * height + ((double)row - 1 - (rows - 1) / 2.0) * s.verticalSpacing;
}
