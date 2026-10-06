#ifndef VL_LAYOUT_H
#define VL_LAYOUT_H
#include <stdbool.h>
#include <stddef.h>
#ifdef __cplusplus
extern "C" {
#endif

/* Zero dimensions mean native Apple layout. Offsets are fractions of list bounds.
 * Spacing is an additional distance between cells in UIKit points. */
typedef struct {
    unsigned rows, columns;
    double horizontalSpacing, verticalSpacing, x, y;
} VLLayout;

typedef struct {
    VLLayout saved, snapshot, working;
    bool editing;
} VLSession;

VLLayout VLDefaultLayout(void);
bool VLLayoutValid(VLLayout layout);
bool VLCanFit(unsigned rows, unsigned columns, size_t iconCount, bool hasWidgets);
bool VLBegin(VLSession *session);
bool VLPreview(VLSession *session, VLLayout layout);
void VLCancel(VLSession *session);
bool VLCommit(VLSession *session, bool persistenceSucceeded);
VLLayout VLCurrent(const VLSession *session);
VLLayout VLFittedLayout(VLLayout layout, unsigned rows, unsigned columns,
                       double firstX, double firstY, double lastX, double lastY,
                       double width, double height);
void VLAdjustedOrigin(VLLayout layout, unsigned rows, unsigned columns,
                      long row, long column, double width, double height,
                      double *x, double *y);
#ifdef __cplusplus
}
#endif
#endif
