[Setting category="Trails"]
bool Setting_DrawTrails = false;
[Setting category="Trails" description="Draws 4 lines per car instead of 1. 4x the load."]
bool Setting_Draw4Wheels = false;
[Setting hidden]
uint TrailPointsLength = 1000;
[Setting category="Trails" min="1" max="300" description="1 point per frame. Lower = shorter trails but less processing."];
uint TrailPointsToDraw = 10;
[Setting category="Trails" min="1" max="20" description="Thickness of trails in px"]
uint TrailThickness = 3;


vec4 RandVec4Color() {
    return vec4(
        Math::Rand(.3, 1.0),
        Math::Rand(.3, 1.0),
        Math::Rand(.3, 1.0),
        Math::Rand(.35, .45)
    );
}

class PlayerTrail {
    array<vec3> path;
    array<vec3> dirs;
    array<vec3> lefts;
    uint pathIx = 0;  // pointer to most recent entry in path
    vec4 col;
    PlayerTrail(vec4 &in _col = vec4()) {
        path.Reserve(TrailPointsLength);
        path.Resize(TrailPointsLength);
        dirs.Resize(TrailPointsLength);
        lefts.Resize(TrailPointsLength);
        // print(path.Length);
        // col = _col;
        if (_col.LengthSquared() > 0) col = _col;
        else col = RandVec4Color();
    }
    void AddPoint(vec3 &in p, vec3 &in dir, vec3 &in left) {
        pathIx = (pathIx + 1) % TrailPointsLength;
        // print(pathIx + " / " + path.Length);
        path[pathIx] = p;
        dirs[pathIx] = dir;
        lefts[pathIx] = left;
    }
    void DrawPath() {
        float initLR = Setting_Draw4Wheels ? -1 : 0;
        float initDSign = Setting_Draw4Wheels ? -.7 : 0;
        for (float lr = initLR; lr <= 1; lr += 2) {
            for (float dSign = initDSign; dSign <= 1.01; dSign += 1.7) {
                nvg::BeginPath();
                vec3 p;
                vec3 lp;
                for (uint i = 0; i < TrailPointsToDraw; i++) {
                    uint _ix = (pathIx - i + TrailPointsLength) % TrailPointsLength;
                    p = path[_ix] + (dirs[_ix] * dSign * 1.9) + (lefts[_ix] * lr * 0.9);
                    if (p.LengthSquared() == 0) continue;
                    bool skipDraw = lp.LengthSquared() > 0 && (lp - p).LengthSquared() > 400;
                    try { // sometimes we get a div by 0 error in Camera.Impl:25
                        if (Camera::IsBehind(p)) break;
                        if (i == 0 || skipDraw)
                            nvg::MoveTo(Camera::ToScreenSpace(p));
                        else
                            nvg::LineTo(Camera::ToScreenSpace(p));
                    } catch {
                        continue;
                    }
                    lp = p;
                }
                nvg::LineCap(nvg::LineCapType::Round);
                nvg::StrokeWidth(float(TrailThickness));
                nvg::StrokeColor(col);
                nvg::Stroke();
                nvg::ClosePath();
            }
        }
    }
}
