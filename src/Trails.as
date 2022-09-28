[Setting hidden]
uint TrailPointsLength = 5000;
[Setting hidden]
uint TrailPointsToDraw = 30;

vec4 RandVec4Color() {
    return vec4(
        Math::Rand(.3, 1.0),
        Math::Rand(.3, 1.0),
        Math::Rand(.3, 1.0),
        Math::Rand(.7, .9)
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
        for (float lr = -1; lr <= 1; lr += 2) {
            for (float dSign = -.7; dSign < 2; dSign += 1.7) {
                nvg::BeginPath();
                vec3 p;
                vec3 lp;
                for (uint i = 0; i < TrailPointsToDraw; i++) {
                    uint _ix = (pathIx - i + TrailPointsLength) % TrailPointsLength;
                    p = path[_ix] + (dirs[_ix] * dSign * 1.9) + (lefts[_ix] * lr * 0.9);
                    if (p.LengthSquared() == 0) continue;
                    if (lp.LengthSquared() > 0 && (lp - p).LengthSquared() > 400) break;
                    try { // sometimes we get a div by 0 error in Camera.Impl:25
                        if (Camera::IsBehind(p)) break;
                        if (i == 0)
                            nvg::MoveTo(Camera::ToScreenSpace(p));
                        else
                            nvg::LineTo(Camera::ToScreenSpace(p));
                    } catch {
                        continue;
                    }
                    lp = p;
                }
                nvg::StrokeWidth(3.);
                nvg::StrokeColor(col);
                nvg::Stroke();
                nvg::ClosePath();
            }
        }
    }
}
