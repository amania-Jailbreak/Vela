#include "VelaCore/VLLayout.h"
#include <assert.h>
#include <math.h>
#include <stdio.h>

int main(void) {
    VLSession session = {0};
    VLLayout s = {7, 5, 8, 12, 0.02, -0.03};
    assert(VLLayoutValid(VLDefaultLayout()));
    assert(VLLayoutValid(s));
    assert(VLBegin(&session));
    assert(!VLBegin(&session));
    assert(VLPreview(&session, s));
    assert(session.saved.rows == 0 && VLCurrent(&session).rows == 7);
    VLCancel(&session);
    assert(!session.editing && VLCurrent(&session).rows == 0);
    assert(!VLPreview(&session, s));
    assert(VLBegin(&session) && VLPreview(&session, s));
    assert(!VLCommit(&session, false));
    assert(session.editing && session.saved.rows == 0);
    assert(VLCommit(&session, true));
    assert(!session.editing && session.saved.rows == 7);
    assert(!VLCommit(&session, true));
    assert(VLBegin(&session));
    assert(VLPreview(&session, VLDefaultLayout()));
    VLCancel(&session);
    assert(VLCurrent(&session).rows == 7);
    VLLayout invalid = s; invalid.x = NAN;
    assert(!VLLayoutValid(invalid));
    invalid = s; invalid.columns = 0; assert(!VLLayoutValid(invalid));
    invalid = s; invalid.rows = 11; assert(!VLLayoutValid(invalid));
    invalid = s; invalid.horizontalSpacing = -1; assert(!VLLayoutValid(invalid));
    invalid = s; invalid.verticalSpacing = INFINITY; assert(!VLLayoutValid(invalid));
    assert(VLCanFit(7, 5, 35, false));
    assert(!VLCanFit(7, 5, 36, false));
    assert(!VLCanFit(7, 5, 1, true));
    double x = 100, y = 100;
    VLAdjustedOrigin(s, 7, 5, 4, 3, 400, 600, &x, &y);
    assert(fabs(x - 108) < 1e-9 && fabs(y - 82) < 1e-9);
    double left = 0, right = 0, top = 0, bottom = 0;
    VLAdjustedOrigin(s, 7, 5, 1, 1, 400, 600, &left, &top);
    VLAdjustedOrigin(s, 7, 5, 7, 5, 400, 600, &right, &bottom);
    assert(fabs(right - left - 32) < 1e-9 && fabs(bottom - top - 72) < 1e-9);
    VLLayout edge = {6, 5, 16, 16, .15, .15};
    edge = VLFittedLayout(edge, 6, 5, 9, 20, 321, 440, 390, 550);
    left = 9; top = 20; right = 321; bottom = 440;
    VLAdjustedOrigin(edge, 6, 5, 1, 1, 390, 550, &left, &top);
    VLAdjustedOrigin(edge, 6, 5, 6, 5, 390, 550, &right, &bottom);
    assert(left >= 0 && top >= 0 && right + 60 <= 390 && bottom + 76 <= 550);
    assert((right - left) / 4 >= 60 && (bottom - top) / 5 >= 76);
    puts("PASS: session preview/cancel/commit/save failure, reset rollback, validation, capacity, widgets, normalized geometry");
    return 0;
}
