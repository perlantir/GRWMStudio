// GRWM v2 — Shared primitives across all four Studio variants.
// FaceMock, StickerSparkle, StickerHeart, StickerStar, gradient/conic helpers.

// GRWM STUDIO LOGO — L01 Bubblegum Stack lockup (the chosen brand mark)
// Two layouts: "stack" (logo over STUDIO, big hero use) and "row" (single line, top bars).
// Sizes scale via `size` prop (1 = ~96px GRWM type; 0.3 ≈ 28px row use).
function GRWMLogo({
  size = 1,
  layout = 'stack',
  pink = '#FF3DA5',
  deep = '#C5187A',
}) {
  const grwmSize = 96 * size;
  const studioSize = layout === 'stack' ? 32 * size : 18 * size;
  const heartSize = 34 * size;
  const font = "'Fredoka','Quicksand',system-ui,sans-serif";

  if (layout === 'row') {
    return (
      <div style={{ display:'inline-flex', alignItems:'center', gap: 8 * size, lineHeight:0.85 }}>
        <span style={{
          fontFamily: font, fontWeight: 700, fontSize: grwmSize * 0.34,
          color: pink, letterSpacing: '-0.02em', position:'relative',
          textShadow: `0 ${3 * size}px 0 ${deep}`,
          WebkitTextStroke: `${1.6 * size}px #fff`, paintOrder: 'stroke fill',
        }}>GRWM</span>
        <svg width={heartSize * 0.42} height={heartSize * 0.42} viewBox="0 0 32 32" style={{ flexShrink:0 }}>
          <path d="M16 28S2 19 2 11a6 6 0 0111-3 6 6 0 0111 3c0 8-14 17-14 17z" fill={deep} stroke="#fff" strokeWidth="3" strokeLinejoin="round"/>
        </svg>
        <span style={{
          fontFamily: font, fontWeight: 700, fontSize: studioSize * 0.7,
          color: deep, letterSpacing: '0.28em', paddingLeft:'0.28em',
        }}>STUDIO</span>
      </div>
    );
  }

  return (
    <div style={{ display:'inline-block', textAlign:'center' }}>
      <div style={{ position:'relative', display:'inline-block' }}>
        <div style={{
          fontFamily: font, fontWeight: 700, fontSize: grwmSize, lineHeight: 0.85,
          color: pink, letterSpacing: '-0.02em',
          textShadow: `0 ${7 * size}px 0 ${deep}, 0 ${12 * size}px ${22 * size}px rgba(197,24,122,0.4)`,
          WebkitTextStroke: `${4 * size}px #fff`, paintOrder: 'stroke fill',
        }}>
          GRWM
        </div>
        <svg width={heartSize} height={heartSize} viewBox="0 0 32 32" style={{ position:'absolute', top: -16 * size, right: -38 * size }}>
          <path d="M16 28S2 19 2 11a6 6 0 0111-3 6 6 0 0111 3c0 8-14 17-14 17z" fill={deep} stroke="#fff" strokeWidth="3" strokeLinejoin="round"/>
        </svg>
      </div>
      <div style={{
        marginTop: 10 * size,
        fontFamily: font, fontWeight: 700, fontSize: studioSize, color: deep,
        letterSpacing: '0.32em', paddingLeft:'0.32em',
      }}>STUDIO</div>
    </div>
  );
}


// Stylized face used as the camera viewport stand-in. Skin tone + makeup
// overlay opacity are tweakable per variant so each flavor's "applied makeup"
// reads in its own palette.
function FaceMock({
  skin = '#FFD9C0',
  blushColor = '#FF7AA2',
  blushOpacity = 0.55,
  lipColor = '#E91E63',
  lipShine = '#FFB7D5',
  eyeShadow = '#C9A8FF',
  eyeShadowOpacity = 0.6,
  freckles = false,
  smile = true,
  size = 1,
}) {
  return (
    <svg viewBox="0 0 280 360" width={280 * size} height={360 * size} style={{ display: 'block' }}>
      <defs>
        <radialGradient id="grwm-skin-shade" cx="0.5" cy="0.45" r="0.7">
          <stop offset="0" stopColor={skin}/>
          <stop offset="1" stopColor="#000" stopOpacity="0.18"/>
        </radialGradient>
        <radialGradient id="grwm-blush" cx="0.5" cy="0.5" r="0.5">
          <stop offset="0" stopColor={blushColor} stopOpacity={blushOpacity}/>
          <stop offset="1" stopColor={blushColor} stopOpacity="0"/>
        </radialGradient>
        <linearGradient id="grwm-lip" x1="0" x2="0" y1="0" y2="1">
          <stop offset="0" stopColor={lipColor}/>
          <stop offset="1" stopColor={lipColor} stopOpacity="0.85"/>
        </linearGradient>
        <linearGradient id="grwm-eyeshadow" x1="0" x2="0" y1="0" y2="1">
          <stop offset="0" stopColor={eyeShadow} stopOpacity={eyeShadowOpacity}/>
          <stop offset="1" stopColor={eyeShadow} stopOpacity="0"/>
        </linearGradient>
      </defs>
      {/* hair back */}
      <path d="M40 130 Q40 40 140 30 Q240 40 240 130 L240 320 L40 320 Z" fill="#3A2530" opacity="0.92"/>
      {/* face */}
      <ellipse cx="140" cy="180" rx="92" ry="118" fill="url(#grwm-skin-shade)"/>
      {/* hair front */}
      <path d="M50 130 Q60 80 140 70 Q220 80 230 130 Q220 110 200 110 Q180 95 160 100 L130 92 Q100 95 90 115 Q70 115 60 130 Z" fill="#3A2530"/>
      {/* eyeshadow */}
      <path d="M86 150 Q104 134 122 152 Q104 162 86 158 Z" fill="url(#grwm-eyeshadow)"/>
      <path d="M158 152 Q176 134 194 150 Q176 162 158 158 Z" fill="url(#grwm-eyeshadow)"/>
      {/* eyes */}
      <ellipse cx="104" cy="160" rx="7" ry="9" fill="#3A2530"/>
      <ellipse cx="176" cy="160" rx="7" ry="9" fill="#3A2530"/>
      <circle cx="106" cy="158" r="2" fill="#fff"/>
      <circle cx="178" cy="158" r="2" fill="#fff"/>
      {/* lashes */}
      <path d="M94 150 q-3 -3 -6 -1 M100 148 q-2 -4 -5 -3 M106 147 q0 -4 -2 -4 M112 148 q2 -4 5 -3 M118 150 q3 -3 6 -1" stroke="#3A2530" strokeWidth="1.4" fill="none" strokeLinecap="round"/>
      <path d="M166 150 q-3 -3 -6 -1 M172 148 q-2 -4 -5 -3 M178 147 q0 -4 -2 -4 M184 148 q2 -4 5 -3 M190 150 q3 -3 6 -1" stroke="#3A2530" strokeWidth="1.4" fill="none" strokeLinecap="round"/>
      {/* brows */}
      <path d="M86 138 Q104 130 122 138" stroke="#2A1820" strokeWidth="3.5" fill="none" strokeLinecap="round"/>
      <path d="M158 138 Q176 130 194 138" stroke="#2A1820" strokeWidth="3.5" fill="none" strokeLinecap="round"/>
      {/* nose */}
      <path d="M138 178 Q133 210 138 222 Q142 226 148 222" stroke="#000" strokeWidth="1.4" strokeOpacity="0.18" fill="none" strokeLinecap="round"/>
      {/* blush */}
      <ellipse cx="92" cy="208" rx="22" ry="14" fill="url(#grwm-blush)"/>
      <ellipse cx="188" cy="208" rx="22" ry="14" fill="url(#grwm-blush)"/>
      {/* freckles (optional) */}
      {freckles && (
        <g fill="#9B6A50" opacity="0.55">
          <circle cx="120" cy="195" r="1.4"/>
          <circle cx="128" cy="200" r="1.2"/>
          <circle cx="152" cy="200" r="1.4"/>
          <circle cx="160" cy="195" r="1.2"/>
          <circle cx="140" cy="208" r="1"/>
        </g>
      )}
      {/* lips */}
      {smile ? (
        <g>
          <path d="M114 252 Q128 246 140 250 Q152 246 166 252 Q160 268 140 270 Q120 268 114 252 Z" fill="url(#grwm-lip)"/>
          <path d="M122 254 Q140 248 158 254" stroke={lipShine} strokeWidth="2" fill="none" strokeLinecap="round" opacity="0.7"/>
          <path d="M118 256 Q140 250 162 256" stroke={lipColor} strokeOpacity="0.4" strokeWidth="0.8" fill="none"/>
        </g>
      ) : (
        <g>
          <path d="M118 254 Q140 248 162 254 Q160 262 140 264 Q120 262 118 254 Z" fill="url(#grwm-lip)"/>
          <path d="M126 254 Q140 250 154 254" stroke={lipShine} strokeWidth="1.6" fill="none" strokeLinecap="round" opacity="0.6"/>
        </g>
      )}
      {/* face tracking dots — overlay vibe */}
      <g fill="none" strokeOpacity="0.55" strokeWidth="1">
        <circle cx="140" cy="180" r="92" stroke="currentColor" strokeDasharray="2 6"/>
      </g>
    </svg>
  );
}

// Tracking dots — face landmark scatter for AR-feel
function FaceTrackingDots({ color = 'rgba(255,255,255,0.55)' }) {
  const pts = [
    [76, 152], [104, 130], [140, 122], [176, 130], [204, 152],
    [80, 200], [104, 218], [140, 234], [176, 218], [200, 200],
    [110, 268], [140, 282], [170, 268],
    [60, 180], [220, 180],
    [128, 195], [152, 195],
  ];
  return (
    <svg viewBox="0 0 280 360" width="100%" height="100%" style={{ position:'absolute', inset:0, pointerEvents:'none' }}>
      {pts.map(([x,y], i) => (
        <circle key={i} cx={x} cy={y} r="1.6" fill={color}>
          <animate attributeName="opacity" values="0.3;1;0.3" dur="2s" begin={`${i*0.05}s`} repeatCount="indefinite"/>
        </circle>
      ))}
    </svg>
  );
}

// Sticker primitives — flat SVG, slightly tilted by parent
function StickerHeart({ size = 28, fill = '#FF1493', stroke = '#fff', sw = 2.5 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 32 32">
      <path d="M16 28S2 19 2 11a6 6 0 0111-3 6 6 0 0111 3c0 8-14 17-14 17z" fill={fill} stroke={stroke} strokeWidth={sw} strokeLinejoin="round"/>
    </svg>
  );
}
function StickerStar({ size = 26, fill = '#FFD66B', stroke = '#fff', sw = 2.5 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 32 32">
      <path d="M16 2l4 9 10 1-7 7 2 10-9-5-9 5 2-10-7-7 10-1z" fill={fill} stroke={stroke} strokeWidth={sw} strokeLinejoin="round"/>
    </svg>
  );
}
function StickerSparkle({ size = 22, fill = '#fff', stroke = null }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24">
      <path d="M12 2l2 7 7 2-7 2-2 7-2-7-7-2 7-2z" fill={fill} stroke={stroke || 'none'} strokeWidth={1.5} strokeLinejoin="round"/>
    </svg>
  );
}
function StickerFlower({ size = 32, petal = '#FF6FAF', center = '#FFD66B', stroke = '#fff', sw = 2 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 32 32">
      <g stroke={stroke} strokeWidth={sw}>
        <circle cx="16" cy="6" r="5" fill={petal}/>
        <circle cx="6" cy="16" r="5" fill={petal}/>
        <circle cx="26" cy="16" r="5" fill={petal}/>
        <circle cx="16" cy="26" r="5" fill={petal}/>
        <circle cx="9" cy="9" r="4.5" fill={petal}/>
        <circle cx="23" cy="9" r="4.5" fill={petal}/>
        <circle cx="9" cy="23" r="4.5" fill={petal}/>
        <circle cx="23" cy="23" r="4.5" fill={petal}/>
        <circle cx="16" cy="16" r="5" fill={center}/>
      </g>
    </svg>
  );
}
function StickerBow({ size = 32, fill = '#FF6FAF', stroke = '#fff', sw = 2 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 36 24">
      <path d="M18 12 L4 4 L4 20 Z" fill={fill} stroke={stroke} strokeWidth={sw} strokeLinejoin="round"/>
      <path d="M18 12 L32 4 L32 20 Z" fill={fill} stroke={stroke} strokeWidth={sw} strokeLinejoin="round"/>
      <ellipse cx="18" cy="12" rx="3.5" ry="4.5" fill={fill} stroke={stroke} strokeWidth={sw}/>
    </svg>
  );
}

// A holographic/metallic gradient for chips, type, and shimmer overlays
const HOLO_GRADIENT = 'conic-gradient(from 90deg, #FFB3D9, #B3D9FF, #FFFAB3, #FFB3FF, #B3FFE5, #FFB3D9)';
const HOLO_SOFT = 'linear-gradient(135deg, #FFE9F2 0%, #E9F2FF 33%, #FFFCE9 66%, #FFE9FC 100%)';

// Precise iOS dynamic island + status bar mimicking IOSStatusBar but with custom colors
function GStatusBar({ color = '#000', time = '9:41' }) {
  return (
    <div style={{
      height: 54, padding: '17px 32px 0',
      display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start',
      pointerEvents: 'none',
      fontFamily: '-apple-system, "SF Pro Text", system-ui',
      fontSize: 17, fontWeight: 600, color,
    }}>
      <div>{time}</div>
      <div style={{ display: 'flex', gap: 7, alignItems: 'center' }}>
        {/* signal */}
        <svg width="18" height="11" viewBox="0 0 18 11"><g fill={color}>
          <rect x="0" y="7" width="3" height="4" rx="0.5"/>
          <rect x="5" y="5" width="3" height="6" rx="0.5"/>
          <rect x="10" y="2" width="3" height="9" rx="0.5"/>
          <rect x="15" y="0" width="3" height="11" rx="0.5"/>
        </g></svg>
        {/* wifi */}
        <svg width="16" height="12" viewBox="0 0 16 12" fill={color}>
          <path d="M8 11.5l1.5-1.8a1.9 1.9 0 0 0-3 0L8 11.5z"/>
          <path d="M11.4 7.5a4.8 4.8 0 0 0-6.8 0l1 1.2a3.3 3.3 0 0 1 4.7 0l1.1-1.2z"/>
          <path d="M14.2 4.4a8.7 8.7 0 0 0-12.4 0l1 1.2a7.2 7.2 0 0 1 10.4 0l1-1.2z"/>
        </svg>
        {/* battery */}
        <svg width="27" height="12" viewBox="0 0 27 12">
          <rect x="0.5" y="0.5" width="22" height="11" rx="3" fill="none" stroke={color} strokeOpacity="0.4"/>
          <rect x="2" y="2" width="19" height="8" rx="1.5" fill={color}/>
          <rect x="23.5" y="4" width="2" height="4" rx="0.7" fill={color} opacity="0.4"/>
        </svg>
      </div>
    </div>
  );
}

// Home indicator
function GHomeIndicator({ color = 'rgba(0,0,0,0.3)' }) {
  return (
    <div style={{ position:'absolute', bottom:0, left:0, right:0, height:34, display:'flex', justifyContent:'center', alignItems:'flex-end', paddingBottom:8, pointerEvents:'none', zIndex:80 }}>
      <div style={{ width:139, height:5, borderRadius:99, background:color }}/>
    </div>
  );
}

// Dynamic island
function GDynamicIsland() {
  return <div style={{ position:'absolute', top:11, left:'50%', transform:'translateX(-50%)', width:126, height:37, borderRadius:24, background:'#000', zIndex:50 }}/>;
}

// Phone shell — same dimensions as IOSDevice but no chrome we don't want
function GPhone({ children, bg = '#FFF6F4', radius = 48, w = 402, h = 874, ringColor = 'rgba(0,0,0,0.12)' }) {
  return (
    <div style={{
      width: w, height: h, borderRadius: radius, overflow: 'hidden',
      position: 'relative', background: bg,
      boxShadow: `0 40px 80px rgba(0,0,0,0.18), 0 0 0 1px ${ringColor}`,
    }}>
      {children}
    </div>
  );
}

// Touch-target debug helper (off by default)
const TT = (children, label) => children;

Object.assign(window, {
  FaceMock, FaceTrackingDots,
  StickerHeart, StickerStar, StickerSparkle, StickerFlower, StickerBow,
  HOLO_GRADIENT, HOLO_SOFT,
  GStatusBar, GHomeIndicator, GDynamicIsland, GPhone, TT,
});
