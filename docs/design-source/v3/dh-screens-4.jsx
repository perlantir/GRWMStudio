// GRWM Studio — Save / Share post-capture screen
// User just snapped a look in the mirror; now they can name, tag, and share it.

function DHSaveShare() {
  return (
    <GPhone bg={DH.PINK_PAPER} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`linear-gradient(180deg, ${DH.PINK_PAPER}, ${DH.CREAM})` }}/>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      {/* Header: cancel / title / done */}
      <div style={{ padding:'4px 18px 0', display:'flex', alignItems:'center', justifyContent:'space-between', position:'relative', zIndex:5 }}>
        <button style={{
          padding:'8px 14px', borderRadius:99, background:'rgba(255,255,255,0.55)', border:'none', cursor:'pointer',
          fontFamily:DH.font, fontWeight:700, fontSize:12, color:DH.PINK_DEEP,
        }}>✕ Cancel</button>
        <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:14, color:DH.PINK_DEEP, letterSpacing:'0.08em' }}>NEW LOOK</div>
        <div style={{ width:80 }}/>
      </div>

      {/* Polaroid preview */}
      <div style={{ padding:'18px 32px 0', position:'relative', zIndex:5 }}>
        <div style={{
          background:'#fff', borderRadius:18, padding:'12px 12px 50px',
          boxShadow: DH.shadowLg(DH.PINK), transform:'rotate(-2deg)', position:'relative',
        }}>
          <div style={{
            height:280, borderRadius:12, position:'relative', overflow:'hidden',
            background:`linear-gradient(180deg, ${DH.PINK_LIGHT}, ${DH.PINK})`,
          }}>
            {/* face */}
            <div style={{ position:'absolute', bottom:-10, left:'50%', transform:'translateX(-50%) scale(1.15)' }}>
              <FaceMock skin="#FFD9C0" lipColor={DH.PINK_DEEP} lipShine="#fff" blushColor={DH.PINK} blushOpacity={0.55} eyeShadow={DH.LAV} eyeShadowOpacity={0.6} smile size={1.0}/>
            </div>
            {/* sparkles overlay */}
            <div style={{ position:'absolute', top:14, left:18 }}><StickerSparkle size={20} fill="#fff"/></div>
            <div style={{ position:'absolute', top:36, right:24 }}><StickerSparkle size={14} fill={DH.BUTTER}/></div>
            <div style={{ position:'absolute', bottom:60, right:18 }}><StickerSparkle size={18} fill="#fff"/></div>
            {/* timestamp pill */}
            <div style={{
              position:'absolute', top:10, left:10, padding:'4px 8px', borderRadius:8,
              background:'rgba(0,0,0,0.4)', backdropFilter:'blur(6px)',
              fontFamily:DH.font, fontWeight:700, fontSize:9, color:'#fff', letterSpacing:'0.12em',
            }}>02 MAY · 9:41 PM</div>
          </div>
          {/* polaroid caption (handwritten-ish) */}
          <div style={{
            position:'absolute', bottom:14, left:0, right:0, textAlign:'center',
            fontFamily:'Caveat,Fredoka,cursive', fontWeight:600, fontSize:22, color:DH.PINK_DEEP, transform:'rotate(-1deg)',
          }}>♡ feeling pink today</div>
          {/* tape */}
          <div style={{
            position:'absolute', top:-10, right:24, width:64, height:20, background:'rgba(255,214,107,0.7)',
            transform:'rotate(8deg)', boxShadow:`0 2px 4px rgba(212,18,123,0.2)`,
          }}/>
        </div>
      </div>

      {/* Name input + tag chips */}
      <div style={{ padding:'30px 18px 0', position:'relative', zIndex:5 }}>
        <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:11, color:'rgba(58,14,37,0.55)', letterSpacing:'0.16em', marginBottom:8 }}>NAME THIS LOOK</div>
        <DHCard color="#fff" deep={DH.PINK_LIGHT} br={20} pad={14} style={{ display:'flex', alignItems:'center', gap:10 }}>
          <span style={{ fontFamily:DH.font, fontWeight:700, fontSize:18, color:DH.INK, flex:1 }}>Bubblegum Pop ✨</span>
          <button style={{
            width:32, height:32, borderRadius:16, background:DH.PINK_PAPER, border:'none', cursor:'pointer',
            display:'flex', alignItems:'center', justifyContent:'center',
          }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round"><path d="M12 20h9M16.5 3.5a2.121 2.121 0 113 3L7 19l-4 1 1-4 12.5-12.5z"/></svg>
          </button>
        </DHCard>

        <div style={{ marginTop:14, fontFamily:DH.font, fontWeight:700, fontSize:11, color:'rgba(58,14,37,0.55)', letterSpacing:'0.16em', marginBottom:8 }}>VIBE TAGS</div>
        <div style={{ display:'flex', flexWrap:'wrap', gap:6 }}>
          <DHChip sel>♡ Cute</DHChip>
          <DHChip sel>✦ Glossy</DHChip>
          <DHChip>Bold</DHChip>
          <DHChip>Daytime</DHChip>
          <DHChip>+ Add</DHChip>
        </div>
      </div>

      {/* Share-to row */}
      <div style={{ padding:'18px 18px 0', position:'relative', zIndex:5 }}>
        <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:11, color:'rgba(58,14,37,0.55)', letterSpacing:'0.16em', marginBottom:8 }}>SHARE WITH</div>
        <div style={{ display:'flex', gap:10, justifyContent:'space-between' }}>
          <ShareDot color={DH.PINK} deep={DH.PINK_DEEP} label="Bestie" emoji="👯"/>
          <ShareDot color={DH.LAV} deep="#7A53C9" label="Squad" emoji="✨"/>
          <ShareDot color={DH.BUTTER} deep="#C99B1F" label="Story" emoji="📸" inkColor={DH.INK}/>
          <ShareDot color={DH.MINT} deep="#5DBD8E" label="Save" emoji="💾" inkColor={DH.INK}/>
          <ShareDot color="#fff" deep={DH.PINK_LIGHT} label="More" emoji="…" inkColor={DH.PINK_DEEP}/>
        </div>
      </div>

      {/* Spacer to keep CTA from hugging share dots */}
      <div style={{ height: 130 }}/>

      {/* Big CTA */}
      <div style={{ position:'absolute', bottom:46, left:18, right:18, zIndex:5 }}>
        <DHButton kind="primary" size="xl" style={{ width:'100%' }}
          icon={<svg width="22" height="22" viewBox="0 0 24 24" fill={DH.BUTTER} stroke="#fff" strokeWidth="1.6"><path d="M12 21S2 14 2 8a5 5 0 019-3 5 5 0 019 3c0 6-8 13-8 13z"/></svg>}>
          Save to Locker
        </DHButton>
      </div>

      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}

function ShareDot({ color, deep, label, emoji, inkColor='#fff' }) {
  return (
    <button style={{
      display:'flex', flexDirection:'column', alignItems:'center', gap:6, background:'none', border:'none', cursor:'pointer',
    }}>
      <div style={{
        width:54, height:54, borderRadius:27, background:color, color:inkColor,
        boxShadow: DH.shadow(deep),
        display:'flex', alignItems:'center', justifyContent:'center', fontSize:22,
      }}>{emoji}</div>
      <span style={{ fontFamily:DH.font, fontWeight:700, fontSize:11, color:DH.INK, letterSpacing:'0.04em' }}>{label}</span>
    </button>
  );
}
window.DHSaveShare = DHSaveShare;

// =====================================================================
// PROFILE / LOCKER — user's identity hub
function DHProfile() {
  return (
    <GPhone bg={DH.CREAM} ringColor="rgba(212,18,123,0.25)">
      {/* pink top hero */}
      <div style={{ position:'absolute', top:0, left:0, right:0, height:300, background:`linear-gradient(180deg, ${DH.PINK} 0%, ${DH.PINK_LIGHT} 100%)` }}/>
      {/* scallop divider */}
      <svg width="100%" height="20" viewBox="0 0 402 20" preserveAspectRatio="none" style={{ position:'absolute', top:300, left:0 }}>
        <path d="M0 0 Q 13 20, 26 0 T 52 0 T 78 0 T 104 0 T 130 0 T 156 0 T 182 0 T 208 0 T 234 0 T 260 0 T 286 0 T 312 0 T 338 0 T 364 0 T 390 0 L 402 0 L 402 20 L 0 20 Z" fill={DH.CREAM}/>
      </svg>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color="#fff"/></div>

      {/* top icons */}
      <div style={{ padding:'4px 18px 0', display:'flex', alignItems:'center', justifyContent:'space-between', position:'relative', zIndex:5 }}>
        <button style={{
          width:42, height:42, borderRadius:21, background:'rgba(255,255,255,0.3)', border:'none', cursor:'pointer',
          backdropFilter:'blur(8px)', display:'flex', alignItems:'center', justifyContent:'center',
        }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.6" strokeLinecap="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 11-2.83 2.83l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 11-4 0v-.09a1.65 1.65 0 00-1-1.51 1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 11-2.83-2.83l.06-.06a1.65 1.65 0 00.33-1.82 1.65 1.65 0 00-1.51-1H3a2 2 0 110-4h.09a1.65 1.65 0 001.51-1 1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 112.83-2.83l.06.06a1.65 1.65 0 001.82.33H9a1.65 1.65 0 001-1.51V3a2 2 0 114 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 112.83 2.83l-.06.06a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H21a2 2 0 110 4h-.09a1.65 1.65 0 00-1.51 1z"/></svg>
        </button>
        <button style={{
          width:42, height:42, borderRadius:21, background:'rgba(255,255,255,0.3)', border:'none', cursor:'pointer',
          backdropFilter:'blur(8px)', display:'flex', alignItems:'center', justifyContent:'center',
        }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.6" strokeLinecap="round"><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><path d="M8.6 13.5l6.8 4M15.4 6.5l-6.8 4"/></svg>
        </button>
      </div>

      {/* Avatar circle */}
      <div style={{ padding:'18px 0 0', display:'flex', flexDirection:'column', alignItems:'center', position:'relative', zIndex:5 }}>
        <div style={{
          width:120, height:120, borderRadius:60, background:'#fff', position:'relative',
          boxShadow:`0 6px 0 ${DH.PINK_DEEP}, 0 12px 24px rgba(212,18,123,0.4)`,
          border:`5px solid #fff`, overflow:'hidden',
        }}>
          <div style={{ position:'absolute', inset:0, background:DH.PINK_LIGHT, display:'flex', alignItems:'flex-end', justifyContent:'center', overflow:'hidden' }}>
            <div style={{ transform:'translateY(8px) scale(0.7)', transformOrigin:'bottom center' }}>
              <FaceMock skin="#FFD4B8" lipColor={DH.PINK_DEEP} blushColor={DH.PINK} eyeShadow={DH.LAV} smile size={1.0}/>
            </div>
          </div>
          {/* online dot */}
          <div style={{
            position:'absolute', bottom:8, right:8, width:18, height:18, borderRadius:9, background:DH.MINT,
            border:`3px solid #fff`,
          }}/>
        </div>
        {/* edit pill */}
        <button style={{
          marginTop:8, padding:'5px 12px', borderRadius:99, background:DH.BUTTER, border:`3px solid #fff`, cursor:'pointer',
          boxShadow:`0 3px 0 #C99B1F`,
          fontFamily:DH.font, fontWeight:800, fontSize:10, color:DH.INK, letterSpacing:'0.08em',
        }}>EDIT AVATAR</button>

        <div style={{ marginTop:10, fontFamily:DH.font, fontWeight:800, fontSize:26, color:'#fff', letterSpacing:'-0.02em', textShadow:`0 3px 0 ${DH.PINK_DEEP}` }}>@stellaglow</div>
        <div style={{ marginTop:2, fontFamily:DH.font, fontWeight:600, fontSize:13, color:'rgba(255,255,255,0.85)' }}>Bubblegum girlie · pisces ♓</div>
      </div>

      {/* Stats card row */}
      <div style={{ padding:'24px 18px 0', display:'flex', gap:8, position:'relative', zIndex:5 }}>
        <DHCard color="#fff" deep={DH.PINK_LIGHT} br={18} pad={12} style={{ flex:1, textAlign:'center' }}>
          <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:22, color:DH.PINK_DEEP, lineHeight:1 }}>24</div>
          <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:10, color:'rgba(58,14,37,0.55)', letterSpacing:'0.1em', marginTop:2 }}>LOOKS</div>
        </DHCard>
        <DHCard color="#fff" deep={DH.PINK_LIGHT} br={18} pad={12} style={{ flex:1, textAlign:'center' }}>
          <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:22, color:DH.PINK_DEEP, lineHeight:1 }}>312</div>
          <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:10, color:'rgba(58,14,37,0.55)', letterSpacing:'0.1em', marginTop:2 }}>FOLLOWERS</div>
        </DHCard>
        <DHCard color="#fff" deep={DH.PINK_LIGHT} br={18} pad={12} style={{ flex:1, textAlign:'center' }}>
          <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:22, color:DH.PINK_DEEP, lineHeight:1 }}>89</div>
          <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:10, color:'rgba(58,14,37,0.55)', letterSpacing:'0.1em', marginTop:2 }}>FOLLOWING</div>
        </DHCard>
      </div>

      {/* Achievement strip */}
      <div style={{ padding:'14px 18px 0', position:'relative', zIndex:5 }}>
        <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:8 }}>
          <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:13, color:DH.INK }}>Glow level <span style={{ color:DH.PINK_DEEP }}>7</span></div>
          <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:11, color:'rgba(58,14,37,0.55)' }}>62 / 100 to lvl 8</div>
        </div>
        <div style={{ height:14, borderRadius:7, background:'#fff', boxShadow:`inset 0 2px 0 rgba(212,18,123,0.15), 0 2px 0 ${DH.PINK_LIGHT}`, overflow:'hidden', position:'relative' }}>
          <div style={{
            height:'100%', width:'62%', borderRadius:7,
            background:`linear-gradient(180deg, ${DH.PINK_LIGHT}, ${DH.PINK})`,
            boxShadow:`inset 0 2px 0 rgba(255,255,255,0.5), inset 0 -2px 0 ${DH.PINK_DEEP}`,
          }}/>
          <div style={{ position:'absolute', top:'50%', left:'62%', transform:'translate(-50%,-50%)' }}>
            <StickerSparkle size={14} fill="#fff"/>
          </div>
        </div>
      </div>

      {/* Recent looks tease */}
      <div style={{ padding:'18px 18px 0', position:'relative', zIndex:5 }}>
        <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:8 }}>
          <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:14, color:DH.INK }}>Recent looks</div>
          <button style={{
            padding:'4px 10px', borderRadius:99, background:'transparent', border:'none', cursor:'pointer',
            fontFamily:DH.font, fontWeight:700, fontSize:11, color:DH.PINK_DEEP,
          }}>See all →</button>
        </div>
        <div style={{ display:'flex', gap:8, overflowX:'auto', paddingBottom:4 }}>
          {[
            { skin:'#FFD9C0', lip:DH.PINK,      eye:DH.LAV,     blush:DH.PINK_LIGHT, color:DH.PINK_LIGHT, deep:DH.PINK_DEEP },
            { skin:'#F5C8A6', lip:'#7AB8FF',   eye:'#7AE8E0', blush:'#A8D8FF',     color:'#C8EAFF',     deep:'#3D7FBF' },
            { skin:'#FFE0CC', lip:'#9C2BFF',   eye:'#FF52E8', blush:'#FFB8DC',     color:'#E8C8FF',     deep:'#5A1099' },
          ].map((l,i) => (
            <DHCard key={i} color={l.color} deep={l.deep} br={18} pad={0} style={{ minWidth:104, height:124, position:'relative', overflow:'hidden' }}>
              <div style={{ position:'absolute', bottom:-22, left:'50%', transform:'translateX(-50%) scale(0.55)' }}>
                <FaceMock skin={l.skin} lipColor={l.lip} eyeShadow={l.eye} blushColor={l.blush} smile size={1.0}/>
              </div>
            </DHCard>
          ))}
        </div>
      </div>

      <DHTabBar active="me"/>
      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}
window.DHProfile = DHProfile;
