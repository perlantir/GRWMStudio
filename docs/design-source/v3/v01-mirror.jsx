// V01 — GRWM STUDIO MIRROR (BUBBLEGUM PLASTIC)
// Glossy bubblegum. Thick chunky shadows. Plastic toy aesthetic.
// Everything looks moulded out of pink plastic with a wet shine.

function V01Dreamhouse() {
  const PINK = '#FF3DA5';
  const PINK_DEEP = '#D4127B';
  const PINK_LIGHT = '#FFB8DC';
  const PINK_PAPER = '#FFE5F2';
  const CREAM = '#FFF6FA';

  // Thick chunky outline + offset shadow for plastic-toy stamping
  const PLASTIC_SHADOW = `0 5px 0 ${PINK_DEEP}, 0 8px 14px rgba(212,18,123,0.4)`;

  return (
    <GPhone bg={PINK_PAPER} ringColor="rgba(212,18,123,0.25)">
      {/* Background — soft striped wallpaper */}
      <div style={{ position:'absolute', inset:0, background:`repeating-linear-gradient(45deg, ${PINK_PAPER} 0 24px, ${CREAM} 24px 48px)`, opacity:0.7 }}/>
      {/* glossy highlight overlay */}
      <div style={{ position:'absolute', top:0, left:0, right:0, height:300, background:'radial-gradient(ellipse at top, rgba(255,255,255,0.7), transparent 70%)', pointerEvents:'none' }}/>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={PINK_DEEP}/></div>

      {/* Top bar */}
      <div style={{ padding:'4px 18px 0', display:'flex', justifyContent:'space-between', alignItems:'center', position:'relative', zIndex:5 }}>
        <button style={{ width:46, height:46, borderRadius:23, background:'#fff', border:'none', cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center', boxShadow:`0 4px 0 ${PINK}, 0 6px 12px rgba(212,18,123,0.3)` }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={PINK_DEEP} strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round"><path d="M15 6l-6 6 6 6"/></svg>
        </button>
        <div style={{
          padding:'8px 14px', borderRadius:99, background:'#fff',
          boxShadow:`0 4px 0 ${PINK}, 0 6px 12px rgba(212,18,123,0.3)`,
          display:'flex', alignItems:'center',
        }}>
          <GRWMLogo size={0.32} layout="row" pink={PINK} deep={PINK_DEEP}/>
        </div>
        <button style={{ width:46, height:46, borderRadius:23, background:PINK, border:'none', cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center', boxShadow:`0 4px 0 ${PINK_DEEP}, 0 6px 12px rgba(212,18,123,0.3)` }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><path d="M7 10l5 5 5-5"/><path d="M12 15V3"/></svg>
        </button>
      </div>

      {/* Mirror viewport — chunky plastic frame */}
      <div style={{ position:'relative', margin:'18px 18px 0', padding:10, borderRadius:36, background:`linear-gradient(180deg, ${PINK} 0%, ${PINK_DEEP} 100%)`, boxShadow:`0 6px 0 ${PINK_DEEP}, 0 14px 28px rgba(212,18,123,0.4), inset 0 2px 0 rgba(255,255,255,0.4)` }}>
        {/* Top scallop trim */}
        <svg width="100%" height="18" viewBox="0 0 360 18" preserveAspectRatio="none" style={{ position:'absolute', top:-9, left:0 }}>
          <path d="M0 18 Q 12 0, 24 18 T 48 18 T 72 18 T 96 18 T 120 18 T 144 18 T 168 18 T 192 18 T 216 18 T 240 18 T 264 18 T 288 18 T 312 18 T 336 18 T 360 18 Z" fill={PINK}/>
        </svg>
        {/* Bow on top */}
        <div style={{ position:'absolute', top:-22, left:'50%', transform:'translateX(-50%) rotate(-4deg)', filter:`drop-shadow(0 3px 0 ${PINK_DEEP})` }}>
          <StickerBow size={56} fill={PINK_LIGHT} stroke="#fff" sw={2.5}/>
        </div>

        <div style={{ position:'relative', borderRadius:28, overflow:'hidden', height:380, background:`radial-gradient(ellipse at center, #FFE0EE 0%, #FFB3D9 100%)`, border:`3px solid #fff` }}>
          {/* sparkles in bg */}
          <div style={{ position:'absolute', top:30, left:30, transform:'rotate(-12deg)', opacity:0.6 }}><StickerSparkle size={20} fill="#fff"/></div>
          <div style={{ position:'absolute', top:100, right:34, transform:'rotate(18deg)' }}><StickerSparkle size={14} fill="#fff"/></div>
          <div style={{ position:'absolute', bottom:120, left:24, transform:'rotate(28deg)', opacity:0.7 }}><StickerSparkle size={18} fill="#fff"/></div>
          <div style={{ position:'absolute', bottom:60, right:20 }}><StickerSparkle size={12} fill="#fff"/></div>

          {/* Face */}
          <div style={{ position:'absolute', bottom:0, left:'50%', transform:'translateX(-50%)' }}>
            <FaceMock skin="#FFD4B8" lipColor={PINK} lipShine="#FFE5F2" blushColor={PINK} blushOpacity={0.5} eyeShadow="#C9A8FF" eyeShadowOpacity={0.45} smile size={1.05}/>
          </div>

          {/* corner heart */}
          <div style={{ position:'absolute', top:14, left:14, padding:'5px 10px', borderRadius:99, background:'rgba(255,255,255,0.85)', display:'flex', alignItems:'center', gap:5, fontFamily:"'Fredoka','Quicksand',system-ui", fontWeight:700, fontSize:11, color:PINK_DEEP, boxShadow:'0 2px 0 rgba(212,18,123,0.25)' }}>
            <StickerHeart size={14} fill={PINK} stroke="#fff" sw={2}/>
            Showtime · 70%
          </div>

          {/* before/after handle */}
          <div style={{ position:'absolute', top:'50%', left:'50%', transform:'translate(-50%,-50%)', width:3, height:300, background:'#fff', boxShadow:`0 0 0 1px ${PINK_DEEP}` }}/>
          <div style={{ position:'absolute', top:'50%', left:'50%', transform:'translate(-50%,-50%)', width:32, height:32, borderRadius:16, background:'#fff', display:'flex', alignItems:'center', justifyContent:'center', boxShadow:`0 3px 0 ${PINK_DEEP}` }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={PINK_DEEP} strokeWidth="3" strokeLinecap="round"><path d="M9 6l-6 6 6 6M15 6l6 6-6 6"/></svg>
          </div>

          {/* face tracking dots */}
          <div style={{ position:'absolute', inset:0, color:'rgba(255,255,255,0.5)' }}><FaceTrackingDots/></div>
        </div>
      </div>

      {/* Category bar — chunky plastic chips */}
      <div style={{ marginTop:18, padding:'0 18px', display:'flex', gap:8 }}>
        {[
          { l:'Lips', sel:true },
          { l:'Eyes', sel:false },
          { l:'Cheek', sel:false },
          { l:'Glow', sel:false },
        ].map(c => (
          <button key={c.l} style={{
            flex:1, height:42, borderRadius:21, border:'none', cursor:'pointer',
            background: c.sel ? '#fff' : 'rgba(255,255,255,0.55)',
            color: c.sel ? PINK_DEEP : 'rgba(212,18,123,0.6)',
            fontFamily:"'Fredoka','Quicksand',system-ui", fontWeight:700, fontSize:13,
            boxShadow: c.sel ? `0 4px 0 ${PINK}, 0 6px 12px rgba(212,18,123,0.25)` : 'none',
            transform: c.sel ? 'translateY(-1px)' : 'none',
          }}>{c.l}</button>
        ))}
      </div>

      {/* Shade dial */}
      <div style={{ marginTop:14, padding:'14px 18px 0', display:'flex', alignItems:'center', justifyContent:'space-between' }}>
        <div>
          <div style={{ fontFamily:"'Fredoka','Quicksand',system-ui", fontWeight:600, fontSize:9, letterSpacing:'0.32em', color:PINK_DEEP, opacity:0.6 }}>SHADE № 007</div>
          <div style={{ fontFamily:"'Fredoka','Quicksand',system-ui", fontWeight:800, fontSize:22, color:PINK_DEEP, lineHeight:1 }}>Showtime</div>
        </div>
        <div style={{ display:'flex', alignItems:'center', gap:8 }}>
          <span style={{ fontFamily:"'Fredoka','Quicksand',system-ui", fontWeight:700, fontSize:11, color:PINK_DEEP }}>matte</span>
          <span style={{ fontFamily:"'Fredoka','Quicksand',system-ui", fontWeight:700, fontSize:11, color:'rgba(212,18,123,0.4)' }}>gloss</span>
        </div>
      </div>

      {/* Shade row — gumball candies */}
      <div style={{ padding:'10px 18px 0', display:'flex', gap:10, justifyContent:'space-between' }}>
        {[
          {c:'#FF8AB8', n:'Sweet'},
          {c:'#FF3DA5', n:'Showtime', sel:true},
          {c:'#D4127B', n:'Diva'},
          {c:'#FFB46B', n:'Honey'},
          {c:'#A8385C', n:'Velvet'},
        ].map(s => (
          <div key={s.n} style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:4 }}>
            <div style={{
              width:48, height:48, borderRadius:24, background:s.c,
              border: s.sel ? `3px solid ${PINK_DEEP}` : '3px solid #fff',
              boxShadow: s.sel ? `0 4px 0 ${PINK_DEEP}, 0 0 0 3px #fff inset, 0 6px 14px rgba(212,18,123,0.4)` : `0 3px 0 rgba(212,18,123,0.3), inset 0 -3px 0 rgba(0,0,0,0.12), inset 0 3px 0 rgba(255,255,255,0.5)`,
              transform: s.sel ? 'translateY(-2px) scale(1.05)' : 'none',
              position:'relative',
            }}>
              {s.sel && <div style={{ position:'absolute', top:-6, right:-6 }}><StickerHeart size={18} fill="#FFD66B" stroke="#fff" sw={2}/></div>}
            </div>
            <span style={{ fontFamily:"'Fredoka','Quicksand',system-ui", fontWeight:600, fontSize:9, color: s.sel ? PINK_DEEP : 'rgba(212,18,123,0.5)' }}>{s.n}</span>
          </div>
        ))}
      </div>

      {/* Bottom action bar */}
      <div style={{ position:'absolute', bottom:0, left:0, right:0, padding:'14px 18px 32px', display:'flex', alignItems:'center', justifyContent:'space-between', gap:10, zIndex:5 }}>
        <button style={{ width:54, height:54, borderRadius:27, background:'#fff', border:'none', cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center', boxShadow:`0 4px 0 ${PINK}, 0 6px 12px rgba(212,18,123,0.3)` }}>
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={PINK_DEEP} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M19 21l-7-5-7 5V5a2 2 0 012-2h10a2 2 0 012 2z"/></svg>
        </button>
        <button style={{
          width:78, height:78, borderRadius:39, background:'#fff', border:`6px solid ${PINK}`, cursor:'pointer',
          display:'flex', alignItems:'center', justifyContent:'center',
          boxShadow:`0 6px 0 ${PINK_DEEP}, 0 10px 22px rgba(212,18,123,0.4)`,
        }}>
          <div style={{ width:50, height:50, borderRadius:25, background:PINK, boxShadow:`inset 0 -4px 0 ${PINK_DEEP}, inset 0 4px 0 rgba(255,255,255,0.4)` }}/>
        </button>
        <button style={{ width:54, height:54, borderRadius:27, background:'#fff', border:'none', cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center', boxShadow:`0 4px 0 ${PINK}, 0 6px 12px rgba(212,18,123,0.3)` }}>
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={PINK_DEEP} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M9 6L3 12l6 6"/><path d="M21 6l-6 6 6 6"/></svg>
        </button>
      </div>

      <GHomeIndicator color={PINK_DEEP}/>
    </GPhone>
  );
}

window.V01Dreamhouse = V01Dreamhouse;
