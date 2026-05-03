// GRWM Studio — Splash & Welcome
// Glossy bubblegum, chunky shadows, plastic-toy moulded UI.
// Reusable design tokens for the whole app live at the top.

const DH = {
  PINK: '#FF3DA5',
  PINK_DEEP: '#D4127B',
  PINK_LIGHT: '#FFB8DC',
  PINK_PAPER: '#FFE5F2',
  CREAM: '#FFF6FA',
  BUTTER: '#FFD66B',
  LAV: '#C9A8FF',
  MINT: '#A8E8C8',
  INK: '#3A0E25',
  // chunky-plastic offset stack
  shadow: (deep) => `0 4px 0 ${deep}, 0 7px 14px rgba(212,18,123,0.3)`,
  shadowLg: (deep) => `0 6px 0 ${deep}, 0 12px 26px rgba(212,18,123,0.4)`,
  font: "'Fredoka','Quicksand',system-ui,sans-serif",
};
window.DH = DH;

// Reusable chunky button (the workhorse)
function DHButton({ children, kind='primary', size='md', icon, iconRight, style, ...rest }) {
  const sizes = {
    sm: { h: 36, px: 14, fs: 12, br: 18 },
    md: { h: 46, px: 18, fs: 14, br: 23 },
    lg: { h: 56, px: 22, fs: 16, br: 28 },
    xl: { h: 64, px: 28, fs: 18, br: 32 },
  };
  const s = sizes[size];
  const palettes = {
    primary: { bg: DH.PINK, color: '#fff', deep: DH.PINK_DEEP },
    white:   { bg: '#fff', color: DH.PINK_DEEP, deep: DH.PINK },
    butter:  { bg: DH.BUTTER, color: DH.INK, deep: '#C99B1F' },
    lav:     { bg: DH.LAV, color: '#fff', deep: '#7A53C9' },
    ghost:   { bg: 'rgba(255,255,255,0.55)', color: DH.PINK_DEEP, deep: 'rgba(212,18,123,0.25)' },
  };
  const p = palettes[kind];
  return (
    <button {...rest} style={{
      height: s.h, padding: `0 ${s.px}px`, borderRadius: s.br,
      background: p.bg, color: p.color, border: 'none', cursor: 'pointer',
      fontFamily: DH.font, fontWeight: 700, fontSize: s.fs, letterSpacing: '0.02em',
      boxShadow: DH.shadow(p.deep),
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      ...style,
    }}>
      {icon}
      {children}
      {iconRight}
    </button>
  );
}
window.DHButton = DHButton;

// Reusable chunky card — plastic-stamped panel
function DHCard({ children, style, color = '#fff', deep = DH.PINK, pad = 16, br = 24, ...rest }) {
  return (
    <div {...rest} style={{
      background: color, borderRadius: br, padding: pad,
      boxShadow: DH.shadow(deep),
      ...style,
    }}>{children}</div>
  );
}
window.DHCard = DHCard;

// Reusable chip (category/tag pill)
function DHChip({ children, sel = false, icon, style, ...rest }) {
  return (
    <button {...rest} style={{
      height: 34, padding: '0 12px', borderRadius: 17, border: 'none', cursor: 'pointer',
      background: sel ? '#fff' : 'rgba(255,255,255,0.5)',
      color: sel ? DH.PINK_DEEP : 'rgba(212,18,123,0.6)',
      fontFamily: DH.font, fontWeight: 700, fontSize: 12,
      boxShadow: sel ? DH.shadow(DH.PINK) : 'none',
      transform: sel ? 'translateY(-1px)' : 'none',
      display: 'inline-flex', alignItems: 'center', gap: 5,
      ...style,
    }}>{icon}{children}</button>
  );
}
window.DHChip = DHChip;

// Tab bar — used across many screens (chunky plastic)
function DHTabBar({ active = 'mirror' }) {
  const tabs = [
    { id: 'mirror', l: 'Mirror', icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><rect x="5" y="3" width="14" height="18" rx="6" stroke="currentColor" strokeWidth="2.4"/><path d="M9 8h6" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round"/></svg> },
    { id: 'looks', l: 'Looks',   icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="2.4"/><circle cx="12" cy="12" r="4" stroke="currentColor" strokeWidth="2.4"/></svg> },
    { id: 'add',    l: '',       icon: null }, // placeholder for the floating action button
    { id: 'feed',   l: 'Feed',   icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M20.84 4.6a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.07a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.07a5.5 5.5 0 000-7.78z" stroke="currentColor" strokeWidth="2.4" strokeLinejoin="round"/></svg> },
    { id: 'me',     l: 'Locker', icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" stroke="currentColor" strokeWidth="2.4"/><path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round"/></svg> },
  ];
  return (
    <div style={{
      position:'absolute', bottom:18, left:14, right:14, height:74, borderRadius:37,
      background:'#fff',
      boxShadow: DH.shadowLg(DH.PINK_DEEP),
      display:'flex', alignItems:'center', justifyContent:'space-between',
      padding:'0 18px',
      zIndex: 30,
    }}>
      {tabs.map(t => {
        if (t.id === 'add') {
          return (
            <button key={t.id} style={{
              width: 64, height: 64, borderRadius: 32, border: `5px solid #fff`, background: DH.PINK, cursor:'pointer',
              boxShadow: `0 5px 0 ${DH.PINK_DEEP}, 0 10px 22px rgba(212,18,123,0.5)`,
              display:'flex', alignItems:'center', justifyContent:'center', transform:'translateY(-22px)',
            }}>
              <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="3.4" strokeLinecap="round"><path d="M12 5v14M5 12h14"/></svg>
            </button>
          );
        }
        const isActive = active === t.id;
        return (
          <button key={t.id} style={{
            display:'flex', flexDirection:'column', alignItems:'center', gap:2,
            background:'none', border:'none', cursor:'pointer',
            color: isActive ? DH.PINK_DEEP : 'rgba(212,18,123,0.4)',
            fontFamily: DH.font, fontWeight: 700, fontSize: 10, letterSpacing: '0.04em',
            position: 'relative',
          }}>
            {t.icon}
            <span>{t.l}</span>
            {isActive && <div style={{ position:'absolute', bottom:-6, width:6, height:6, borderRadius:3, background:DH.PINK }}/>}
          </button>
        );
      })}
    </div>
  );
}
window.DHTabBar = DHTabBar;

// =====================================================================
// SPLASH — animated intro with logo bouncing in
function DHSplash() {
  return (
    <GPhone bg={DH.PINK_PAPER} ringColor="rgba(212,18,123,0.25)">
      {/* Striped wallpaper */}
      <div style={{ position:'absolute', inset:0, background:`repeating-linear-gradient(45deg, ${DH.PINK_PAPER} 0 30px, ${DH.CREAM} 30px 32px)`, opacity:0.7 }}/>
      {/* glossy top sheen */}
      <div style={{ position:'absolute', top:0, left:0, right:0, height:340, background:'radial-gradient(ellipse at top, rgba(255,255,255,0.6), transparent 70%)' }}/>
      {/* sparkles */}
      <div style={{ position:'absolute', top:120, left:30, transform:'rotate(-15deg)' }}><StickerSparkle size={28} fill={DH.PINK}/></div>
      <div style={{ position:'absolute', top:180, right:34 }}><StickerSparkle size={20} fill={DH.BUTTER}/></div>
      <div style={{ position:'absolute', bottom:240, left:60, transform:'rotate(20deg)' }}><StickerSparkle size={22} fill={DH.LAV}/></div>
      <div style={{ position:'absolute', bottom:160, right:40 }}><StickerSparkle size={32} fill={DH.PINK_LIGHT}/></div>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      {/* Centered hero — logo lockup */}
      <div style={{ position:'absolute', inset:0, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', padding:'0 40px', zIndex: 5 }}>
        {/* Bow ribbon above logo */}
        <div style={{ marginBottom: 14, transform:'rotate(-3deg)', filter:`drop-shadow(0 4px 0 ${DH.PINK_DEEP})` }}>
          <StickerBow size={68} fill={DH.PINK_LIGHT} stroke="#fff" sw={3}/>
        </div>

        {/* GRWM Studio logo (L01 — Bubblegum Stack, hero scale) */}
        <GRWMLogo size={1} layout="stack" pink={DH.PINK} deep={DH.PINK_DEEP}/>

        <div style={{
          marginTop: 28,
          fontFamily: DH.font, fontWeight: 500, fontSize: 18, color: DH.INK, opacity: 0.7,
          textAlign:'center', maxWidth: 280, lineHeight: 1.4,
        }}>
          Your studio mirror.<br/>Get ready, but make it&nbsp;sparkle&nbsp;✨
        </div>

        {/* Loader */}
        <div style={{ marginTop:36, width:120, height:8, borderRadius:4, background:'#fff', overflow:'hidden', boxShadow:`inset 0 1px 2px rgba(212,18,123,0.2), 0 2px 0 ${DH.PINK_LIGHT}` }}>
          <div style={{ height:'100%', width:'62%', borderRadius:4, background:`linear-gradient(180deg, ${DH.PINK_LIGHT}, ${DH.PINK})`, boxShadow:`inset 0 -2px 0 ${DH.PINK_DEEP}` }}/>
        </div>
        <div style={{ marginTop:8, fontFamily:DH.font, fontWeight:700, fontSize:11, color:DH.PINK_DEEP, opacity:0.6, letterSpacing:'0.24em' }}>POLISHING THE MIRROR…</div>
      </div>

      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}
window.DHSplash = DHSplash;

// =====================================================================
// WELCOME — multi-card onboarding carousel
function DHWelcome() {
  return (
    <GPhone bg={DH.PINK_PAPER} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`repeating-linear-gradient(45deg, ${DH.PINK_PAPER} 0 24px, ${DH.CREAM} 24px 48px)`, opacity:0.6 }}/>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      {/* skip in top right */}
      <div style={{ padding:'4px 18px 0', display:'flex', justifyContent:'flex-end', position:'relative', zIndex:5 }}>
        <button style={{
          padding:'8px 14px', borderRadius:99, background:'rgba(255,255,255,0.55)', border:'none', cursor:'pointer',
          fontFamily:DH.font, fontWeight:700, fontSize:12, color:DH.PINK_DEEP, letterSpacing:'0.08em',
        }}>Skip ›</button>
      </div>

      {/* Hero illustration card */}
      <div style={{ padding: '12px 18px 0', position:'relative', zIndex:5 }}>
        <DHCard color={DH.PINK_LIGHT} deep={DH.PINK} pad={0} br={32} style={{ position:'relative', overflow:'hidden', height:340 }}>
          {/* scallop top */}
          <svg width="100%" height="14" viewBox="0 0 360 14" preserveAspectRatio="none" style={{ position:'absolute', top:-7, left:0 }}>
            <path d="M0 14 Q 12 0, 24 14 T 48 14 T 72 14 T 96 14 T 120 14 T 144 14 T 168 14 T 192 14 T 216 14 T 240 14 T 264 14 T 288 14 T 312 14 T 336 14 T 360 14 Z" fill={DH.PINK_LIGHT}/>
          </svg>
          {/* face mock */}
          <div style={{ position:'absolute', bottom:-6, left:'50%', transform:'translateX(-50%)' }}>
            <FaceMock skin="#FFD4B8" lipColor={DH.PINK} lipShine="#FFE5F2" blushColor={DH.PINK} blushOpacity={0.5} eyeShadow={DH.LAV} eyeShadowOpacity={0.5} smile size={1.0}/>
          </div>
          {/* sparkles */}
          <div style={{ position:'absolute', top:30, left:30 }}><StickerSparkle size={22} fill="#fff"/></div>
          <div style={{ position:'absolute', top:60, right:36 }}><StickerSparkle size={16} fill={DH.BUTTER}/></div>
          <div style={{ position:'absolute', bottom:80, left:24 }}><StickerSparkle size={14} fill="#fff"/></div>
          {/* heart bubble headline */}
          <div style={{ position:'absolute', top:24, right:20, transform:'rotate(6deg)', filter:`drop-shadow(0 4px 0 ${DH.PINK_DEEP})` }}>
            <div style={{ position:'relative' }}>
              <svg width="84" height="76" viewBox="0 0 32 28">
                <path d="M16 26S2 18 2 10a6 6 0 0111-3 6 6 0 0111 3c0 8-12 16-12 16z" fill="#fff" stroke={DH.PINK_DEEP} strokeWidth="1.8"/>
              </svg>
              <div style={{ position:'absolute', inset:0, display:'flex', alignItems:'center', justifyContent:'center', fontFamily:DH.font, fontWeight:800, fontSize:14, color:DH.PINK_DEEP, paddingTop:4 }}>hey<br/>bestie!</div>
            </div>
          </div>
        </DHCard>
      </div>

      {/* Headline + body */}
      <div style={{ padding:'18px 24px 0', textAlign:'center', position:'relative', zIndex:5 }}>
        <div style={{
          fontFamily: DH.font, fontWeight: 700, fontSize: 36, lineHeight: 0.95, color: DH.PINK_DEEP, letterSpacing:'-0.02em',
        }}>Try every shade.<br/>Save the&nbsp;ones&nbsp;you&nbsp;love.</div>
        <div style={{
          marginTop:10, fontFamily:DH.font, fontWeight:500, fontSize:14, color: DH.INK, opacity: 0.7, lineHeight:1.45, maxWidth:300, marginLeft:'auto', marginRight:'auto',
        }}>Point your camera at your face and we'll do the rest. Mix lips, eyes &amp; cheeks. Save your fav looks to your locker.</div>
      </div>

      {/* Page dots */}
      <div style={{ position:'absolute', bottom:152, left:0, right:0, display:'flex', justifyContent:'center', gap:6, zIndex:5 }}>
        <span style={{ width:24, height:8, borderRadius:4, background:DH.PINK_DEEP, boxShadow:`0 2px 0 ${DH.INK}` }}/>
        <span style={{ width:8, height:8, borderRadius:4, background:'rgba(212,18,123,0.25)' }}/>
        <span style={{ width:8, height:8, borderRadius:4, background:'rgba(212,18,123,0.25)' }}/>
      </div>

      {/* CTA */}
      <div style={{ position:'absolute', bottom:60, left:18, right:18, display:'flex', flexDirection:'column', gap:10, zIndex:5 }}>
        <DHButton kind="primary" size="xl" style={{ width: '100%' }} iconRight={<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.8" strokeLinecap="round"><path d="M5 12h14M13 5l7 7-7 7"/></svg>}>
          Let's go!
        </DHButton>
        <button style={{
          height:46, background:'transparent', border:'none', cursor:'pointer',
          fontFamily:DH.font, fontWeight:700, fontSize:13, color:DH.PINK_DEEP, letterSpacing:'0.06em',
        }}>I already have an account →</button>
      </div>

      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}
window.DHWelcome = DHWelcome;
