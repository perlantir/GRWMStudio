// GRWM Studio — Recording Preview, Saved variants, Parental Gate, Paywall, Settings

// ────────────────────────────────────────────────────────────────────
// RECORDING PREVIEW — Idle (just recorded, scrubbable + share)
function DHPreviewIdle() {
  return (
    <GPhone bg={DH.PINK_PAPER} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`linear-gradient(180deg, ${DH.PINK_PAPER}, ${DH.CREAM} 60%)` }}/>
      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      <div style={{ padding:'4px 18px 0', display:'flex', alignItems:'center', justifyContent:'space-between', position:'relative', zIndex:5 }}>
        <button style={{ width:42, height:42, borderRadius:21, background:'#fff', border:'none', boxShadow:DH.shadow(DH.PINK), display:'flex', alignItems:'center', justifyContent:'center' }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="3" strokeLinecap="round"><path d="M6 6L18 18M18 6L6 18"/></svg>
        </button>
        <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:14, color:DH.PINK_DEEP }}>Preview</div>
        <button style={{
          padding:'8px 14px', borderRadius:99, background:DH.PINK_PAPER, border:'none', boxShadow:`0 3px 0 ${DH.PINK_LIGHT}`,
          fontFamily:DH.font, fontWeight:800, fontSize:12, color:DH.PINK_DEEP, display:'flex', alignItems:'center', gap:5,
        }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="2.6" strokeLinecap="round"><path d="M3 6h18"/><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6"/><path d="M8 6V4a2 2 0 012-2h4a2 2 0 012 2v2"/></svg>
          Discard
        </button>
      </div>

      {/* Video preview card */}
      <div style={{ padding:'14px 18px 0', position:'relative', zIndex:5 }}>
        <DHCard color="#fff" deep={DH.PINK} br={28} pad={10} style={{ position:'relative' }}>
          <div style={{ height:380, borderRadius:20, overflow:'hidden', position:'relative', background:`linear-gradient(180deg, ${DH.PINK_LIGHT}, ${DH.PINK})` }}>
            <div style={{ position:'absolute', bottom:-10, left:'50%', transform:'translateX(-50%) scale(1.2)' }}>
              <FaceMock skin="#FFD9C0" lipColor={DH.PINK_DEEP} lipShine="#fff" blushColor={DH.PINK} blushOpacity={0.55} eyeShadow={DH.LAV} eyeShadowOpacity={0.6} smile size={1.0}/>
            </div>
            {/* Big play */}
            <div style={{ position:'absolute', inset:0, display:'flex', alignItems:'center', justifyContent:'center' }}>
              <div style={{
                width:84, height:84, borderRadius:42, background:'rgba(255,255,255,0.92)',
                boxShadow:`0 6px 0 ${DH.PINK_DEEP}, 0 10px 20px rgba(0,0,0,0.2)`,
                display:'flex', alignItems:'center', justifyContent:'center',
              }}>
                <svg width="38" height="38" viewBox="0 0 24 24" fill={DH.PINK_DEEP}><path d="M7 4l14 8-14 8z"/></svg>
              </div>
            </div>
            {/* Duration pill */}
            <div style={{ position:'absolute', top:14, right:14, padding:'4px 10px', borderRadius:99, background:'rgba(58,14,37,0.65)', backdropFilter:'blur(4px)', fontFamily:DH.font, fontWeight:800, fontSize:11, color:'#fff', letterSpacing:'0.04em' }}>
              0:42
            </div>
          </div>
        </DHCard>
      </div>

      {/* Scrubber */}
      <div style={{ padding:'14px 24px 0', position:'relative', zIndex:5 }}>
        <div style={{ height:6, borderRadius:3, background:'#fff', boxShadow:`inset 0 1px 2px rgba(212,18,123,0.2), 0 2px 0 ${DH.PINK_LIGHT}`, position:'relative' }}>
          <div style={{ height:6, width:'34%', borderRadius:3, background:DH.PINK, boxShadow:`inset 0 -2px 0 ${DH.PINK_DEEP}` }}/>
          <div style={{ position:'absolute', top:'50%', left:'34%', width:18, height:18, borderRadius:9, background:'#fff', border:`3px solid ${DH.PINK_DEEP}`, transform:'translate(-50%,-50%)', boxShadow:`0 3px 6px rgba(212,18,123,0.4)` }}/>
        </div>
        <div style={{ marginTop:6, display:'flex', justifyContent:'space-between', fontFamily:DH.font, fontWeight:700, fontSize:11, color:'rgba(58,14,37,0.55)' }}>
          <span>0:14</span>
          <span>0:42</span>
        </div>
      </div>

      {/* Share row */}
      <div style={{ padding:'18px 18px 0', display:'flex', gap:8, justifyContent:'space-between', position:'relative', zIndex:5 }}>
        {[
          { e:'💌', l:'Text',   c:DH.PINK,        d:DH.PINK_DEEP },
          { e:'📷', l:'Camera', c:DH.LAV,         d:'#5A1099' },
          { e:'⭐', l:'Save',   c:DH.BUTTER,      d:'#C99B1F' },
          { e:'✂️', l:'Trim',   c:'#7AE8E0',      d:'#3A8E89' },
          { e:'🌈', l:'Style',  c:DH.PINK_LIGHT,  d:DH.PINK_DEEP },
        ].map(s => (
          <div key={s.l} style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:5 }}>
            <button style={{
              width:54, height:54, borderRadius:18, background:s.c, border:`3px solid #fff`,
              boxShadow:`0 4px 0 ${s.d}, inset 0 2px 0 rgba(255,255,255,0.45)`,
              fontSize:24, display:'flex', alignItems:'center', justifyContent:'center',
            }}>{s.e}</button>
            <span style={{ fontFamily:DH.font, fontWeight:700, fontSize:10, color:DH.INK }}>{s.l}</span>
          </div>
        ))}
      </div>

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
window.DHPreviewIdle = DHPreviewIdle;

// ────────────────────────────────────────────────────────────────────
// RECORDING PREVIEW — SAVED (success state with confetti)
function DHPreviewSaved() {
  return (
    <GPhone bg={DH.PINK_PAPER} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`linear-gradient(180deg, ${DH.PINK_LIGHT}, ${DH.PINK_PAPER} 50%)` }}/>
      {/* Confetti */}
      <div style={{ position:'absolute', top:140, left:30 }}><StickerSparkle size={28} fill={DH.PINK}/></div>
      <div style={{ position:'absolute', top:200, right:40, transform:'rotate(18deg)' }}><StickerHeart size={26} fill={DH.PINK_DEEP}/></div>
      <div style={{ position:'absolute', top:260, left:60, transform:'rotate(-12deg)' }}><StickerSparkle size={22} fill={DH.BUTTER}/></div>
      <div style={{ position:'absolute', top:160, right:80 }}><StickerSparkle size={16} fill={DH.LAV}/></div>
      <div style={{ position:'absolute', top:120, left:140 }}><StickerHeart size={20} fill={DH.PINK} stroke="#fff" sw={2}/></div>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      {/* Hero badge */}
      <div style={{ padding:'56px 0 0', display:'flex', justifyContent:'center', position:'relative', zIndex:5 }}>
        <div style={{
          width:160, height:160, borderRadius:80, background:`linear-gradient(180deg, ${DH.BUTTER}, #E8A91D)`,
          border:`6px solid #fff`, boxShadow:`0 8px 0 #C99B1F, 0 14px 28px rgba(232,169,29,0.5)`,
          display:'flex', alignItems:'center', justifyContent:'center',
        }}>
          <svg width="88" height="88" viewBox="0 0 24 24" fill="none" stroke={DH.INK} strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round">
            <path d="M5 12l5 5L20 7"/>
          </svg>
        </div>
      </div>

      <div style={{ padding:'24px 28px 0', textAlign:'center', position:'relative', zIndex:5 }}>
        <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:32, color:DH.PINK_DEEP, letterSpacing:'-0.02em', textShadow:`0 4px 0 #fff` }}>
          Saved! ♡
        </div>
        <div style={{ marginTop:8, fontFamily:DH.font, fontWeight:500, fontSize:14, color:'rgba(58,14,37,0.75)', lineHeight:1.5 }}>
          Your look is in the Locker. Find it under <b>Saved Looks</b> any time.
        </div>
      </div>

      {/* Saved card preview */}
      <div style={{ padding:'24px 18px 0', position:'relative', zIndex:5 }}>
        <DHCard color="#fff" deep={DH.PINK} br={22} pad={12} style={{ display:'flex', alignItems:'center', gap:12 }}>
          <div style={{ width:74, height:74, borderRadius:14, background:DH.PINK_LIGHT, overflow:'hidden', position:'relative' }}>
            <div style={{ position:'absolute', bottom:-12, left:'50%', transform:'translateX(-50%) scale(0.5)', transformOrigin:'bottom center' }}>
              <FaceMock skin="#FFD9C0" lipColor={DH.PINK_DEEP} blushColor={DH.PINK} eyeShadow={DH.LAV} smile size={1.0}/>
            </div>
          </div>
          <div style={{ flex:1 }}>
            <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:10, color:'rgba(58,14,37,0.5)', letterSpacing:'0.16em' }}>LOOK № 008</div>
            <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:18, color:DH.PINK_DEEP, lineHeight:1 }}>Bubblegum Pop</div>
            <div style={{ marginTop:4, display:'flex', gap:4 }}>
              <span style={{ fontFamily:DH.font, fontSize:10, fontWeight:700, color:'rgba(58,14,37,0.55)' }}>♡ Cute · 0:42 · just now</span>
            </div>
          </div>
        </DHCard>
      </div>

      <div style={{ position:'absolute', bottom:46, left:18, right:18, display:'flex', gap:10, zIndex:5 }}>
        <DHButton kind="white" size="xl" style={{ flex:1 }}>Done</DHButton>
        <DHButton kind="primary" size="xl" style={{ flex:1.4 }}
          icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="#fff"><path d="M12 21S2 14 2 8a5 5 0 019-3 5 5 0 019 3c0 6-8 13-8 13z"/></svg>}>
          Try another
        </DHButton>
      </div>

      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}
window.DHPreviewSaved = DHPreviewSaved;

// ────────────────────────────────────────────────────────────────────
// LOOKS SAVED — EMPTY STATE (no looks yet)
function DHSavedEmpty() {
  return (
    <GPhone bg={DH.CREAM} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`linear-gradient(180deg, ${DH.PINK_PAPER}, ${DH.CREAM} 30%)` }}/>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      <div style={{ padding:'4px 18px 0', position:'relative', zIndex:5 }}>
        <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:11, color:'rgba(58,14,37,0.5)', letterSpacing:'0.16em' }}>YOUR LOCKER</div>
        <div style={{ marginTop:2, fontFamily:DH.font, fontWeight:700, fontSize:30, color:DH.PINK_DEEP, letterSpacing:'-0.02em', lineHeight:1 }}>Saved Looks ✨</div>
      </div>

      {/* Tabs (looks/saved) */}
      <div style={{ margin:'14px 18px 0', display:'flex', gap:6, padding:5, borderRadius:18, background:'#fff', boxShadow:`0 2px 0 ${DH.PINK_LIGHT}`, position:'relative', zIndex:5 }}>
        <div style={{ flex:1, padding:'8px 0', textAlign:'center', borderRadius:13, fontFamily:DH.font, fontWeight:700, fontSize:13, color:'rgba(58,14,37,0.5)' }}>Looks</div>
        <div style={{ flex:1, padding:'8px 0', textAlign:'center', borderRadius:13, background:DH.PINK, color:'#fff', boxShadow:`0 3px 0 ${DH.PINK_DEEP}`, fontFamily:DH.font, fontWeight:800, fontSize:13 }}>Saved · 0</div>
      </div>

      {/* Empty illustration */}
      <div style={{ padding:'48px 18px 0', display:'flex', flexDirection:'column', alignItems:'center', position:'relative', zIndex:5 }}>
        <div style={{
          width:180, height:180, borderRadius:32, background:'#fff',
          border:`4px dashed ${DH.PINK}`, display:'flex', alignItems:'center', justifyContent:'center',
          position:'relative', boxShadow:`0 5px 0 ${DH.PINK_LIGHT}`,
        }}>
          <div style={{ fontSize:88, transform:'translateY(-2px)' }}>💼</div>
          {/* sticker corners */}
          <div style={{ position:'absolute', top:-12, right:-12, transform:'rotate(15deg)' }}><StickerHeart size={36} fill={DH.PINK_DEEP} stroke="#fff" sw={3}/></div>
          <div style={{ position:'absolute', bottom:-10, left:-10, transform:'rotate(-15deg)' }}><StickerSparkle size={28} fill={DH.BUTTER}/></div>
        </div>

        <div style={{ marginTop:24, fontFamily:DH.font, fontWeight:700, fontSize:24, color:DH.PINK_DEEP, textAlign:'center' }}>
          Your locker is empty 💕
        </div>
        <div style={{ marginTop:8, padding:'0 24px', fontFamily:DH.font, fontWeight:500, fontSize:14, color:'rgba(58,14,37,0.7)', lineHeight:1.5, textAlign:'center', maxWidth:300 }}>
          Make a look in the mirror, hit the heart, and it'll show up here forever.
        </div>
      </div>

      <div style={{ position:'absolute', bottom:140, left:18, right:18, zIndex:5 }}>
        <DHButton kind="primary" size="xl" style={{ width:'100%' }}
          icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.8" strokeLinecap="round"><circle cx="12" cy="12" r="9"/><path d="M12 8v8M8 12h8"/></svg>}>
          Open the Mirror
        </DHButton>
      </div>

      <DHTabBar active="looks"/>
      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}
window.DHSavedEmpty = DHSavedEmpty;

// ────────────────────────────────────────────────────────────────────
// LOOKS SAVED — AT LIMIT (50/50 free, asking to upgrade)
function DHSavedAtLimit() {
  return (
    <GPhone bg={DH.CREAM} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`linear-gradient(180deg, ${DH.PINK_PAPER}, ${DH.CREAM} 30%)` }}/>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      <div style={{ padding:'4px 18px 0', position:'relative', zIndex:5 }}>
        <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:11, color:'rgba(58,14,37,0.5)', letterSpacing:'0.16em' }}>YOUR LOCKER</div>
        <div style={{ marginTop:2, fontFamily:DH.font, fontWeight:700, fontSize:30, color:DH.PINK_DEEP, letterSpacing:'-0.02em', lineHeight:1 }}>Saved Looks ✨</div>
      </div>

      {/* Limit banner */}
      <div style={{ padding:'14px 18px 0', position:'relative', zIndex:5 }}>
        <DHCard color={DH.BUTTER} deep="#C99B1F" br={20} pad={14} style={{ display:'flex', alignItems:'center', gap:10 }}>
          <div style={{ fontSize:30 }}>💼</div>
          <div style={{ flex:1 }}>
            <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:14, color:DH.INK }}>Locker is full!</div>
            <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:11.5, color:'rgba(58,14,37,0.7)' }}>50 of 50 free spots used. Get unlimited?</div>
          </div>
          <button style={{
            padding:'8px 12px', borderRadius:99, background:'#fff',
            boxShadow:`0 3px 0 #C99B1F`, border:'none',
            fontFamily:DH.font, fontWeight:800, fontSize:11, color:DH.INK, letterSpacing:'0.06em',
          }}>UNLOCK ✨</button>
        </DHCard>
      </div>

      {/* Mini grid */}
      <div style={{ padding:'14px 18px 130px', display:'grid', gridTemplateColumns:'1fr 1fr 1fr', gap:8, position:'relative', zIndex:5 }}>
        {Array.from({length:9}).map((_, i) => {
          const palettes = [
            { c:DH.PINK_LIGHT, d:DH.PINK_DEEP, lip:DH.PINK,    eye:DH.LAV },
            { c:DH.LAV,        d:'#5A1099',    lip:'#9C2BFF',  eye:'#FF52E8' },
            { c:DH.BUTTER,     d:'#C99B1F',    lip:'#E8A0A8',  eye:DH.BUTTER },
            { c:'#C8EAFF',     d:'#3D7FBF',    lip:'#7AB8FF',  eye:'#7AE8E0' },
            { c:DH.MINT,       d:'#5DBD8E',    lip:'#7AE8E0',  eye:DH.MINT },
          ];
          const p = palettes[i % palettes.length];
          return (
            <DHCard key={i} color={p.c} deep={p.d} br={14} pad={0} style={{ height:108, position:'relative', overflow:'hidden' }}>
              <div style={{ position:'absolute', bottom:-14, left:'50%', transform:'translateX(-50%) scale(0.55)', transformOrigin:'bottom center' }}>
                <FaceMock skin="#FFD9C0" lipColor={p.lip} eyeShadow={p.eye} blushColor={p.lip} smile size={1.0}/>
              </div>
              {i === 0 && <div style={{ position:'absolute', top:5, right:5 }}><StickerHeart size={14} fill={DH.PINK_DEEP} stroke="#fff" sw={1.5}/></div>}
            </DHCard>
          );
        })}
      </div>

      <DHTabBar active="looks"/>
      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}
window.DHSavedAtLimit = DHSavedAtLimit;

// ────────────────────────────────────────────────────────────────────
// PARENTAL GATE — MATH IDLE (defaults state)
function DHParentMathIdle({ wrong = false }) {
  return (
    <GPhone bg={DH.PINK_PAPER} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`linear-gradient(180deg, ${DH.PINK_LIGHT}, ${DH.PINK_PAPER} 60%)`, opacity:0.95 }}/>
      {/* Decorative kisses */}
      <div style={{ position:'absolute', top:120, left:24, transform:'rotate(-18deg)', opacity:0.5 }}>
        <svg width="120" height="120" viewBox="0 0 24 24" fill={DH.PINK}><path d="M12 21S2 14 2 8a5 5 0 019-3 5 5 0 019 3c0 6-8 13-8 13z"/></svg>
      </div>
      <div style={{ position:'absolute', bottom:160, right:18, transform:'rotate(15deg)', opacity:0.5 }}>
        <svg width="140" height="140" viewBox="0 0 24 24" fill={DH.PINK_DEEP}><path d="M12 21S2 14 2 8a5 5 0 019-3 5 5 0 019 3c0 6-8 13-8 13z"/></svg>
      </div>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      <div style={{ padding:'4px 18px 0', display:'flex', alignItems:'center', justifyContent:'space-between', position:'relative', zIndex:5 }}>
        <button style={{ width:42, height:42, borderRadius:21, background:'#fff', border:'none', boxShadow:DH.shadow(DH.PINK), display:'flex', alignItems:'center', justifyContent:'center' }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="3" strokeLinecap="round"><path d="M6 6L18 18M18 6L6 18"/></svg>
        </button>
        <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:11, color:DH.PINK_DEEP, letterSpacing:'0.16em' }}>GROWN-UP CHECK</div>
        <div style={{ width:42 }}/>
      </div>

      {/* Card with math */}
      <div style={{ padding:'40px 18px 0', position:'relative', zIndex:5 }}>
        <DHCard color="#fff" deep={DH.PINK_DEEP} br={28} pad={24}>
          <div style={{ textAlign:'center' }}>
            <div style={{ fontSize:46 }}>👋</div>
            <div style={{ marginTop:6, fontFamily:DH.font, fontWeight:700, fontSize:22, color:DH.PINK_DEEP, letterSpacing:'-0.02em' }}>
              For grown-ups only
            </div>
            <div style={{ marginTop:6, fontFamily:DH.font, fontWeight:500, fontSize:13, color:'rgba(58,14,37,0.7)', lineHeight:1.45 }}>
              To make a purchase, please solve this:
            </div>
          </div>

          {/* Math chips */}
          <div style={{ marginTop:20, display:'flex', alignItems:'center', justifyContent:'center', gap:10 }}>
            <MathChip n="9"/>
            <span style={{ fontFamily:DH.font, fontWeight:800, fontSize:32, color:DH.PINK_DEEP }}>+</span>
            <MathChip n="6"/>
            <span style={{ fontFamily:DH.font, fontWeight:800, fontSize:32, color:DH.PINK_DEEP }}>=</span>
            <MathChip n="?" hollow/>
          </div>

          {/* Input field */}
          <div style={{
            marginTop:20, padding:'14px 18px', borderRadius:18, background:DH.PINK_PAPER,
            border: wrong ? `3px solid #FF2D5A` : `3px solid ${DH.PINK_LIGHT}`,
            boxShadow: wrong ? `0 4px 0 #B41540` : `0 4px 0 ${DH.PINK_LIGHT}`,
            display:'flex', alignItems:'center', justifyContent:'space-between',
          }}>
            <span style={{ fontFamily:DH.font, fontWeight:800, fontSize:24, color: wrong ? '#FF2D5A' : DH.PINK_DEEP }}>{wrong ? '12' : '___'}</span>
            <span style={{ fontFamily:DH.font, fontWeight:700, fontSize:11, color:'rgba(58,14,37,0.5)', letterSpacing:'0.12em' }}>YOUR ANSWER</span>
          </div>

          {wrong && (
            <div style={{ marginTop:10, padding:'8px 12px', borderRadius:12, background:'#FFE3E9', display:'flex', alignItems:'center', gap:8 }}>
              <span style={{ fontSize:16 }}>🙊</span>
              <span style={{ fontFamily:DH.font, fontWeight:700, fontSize:12, color:'#B41540' }}>Hmm, not quite. Try again!</span>
            </div>
          )}
        </DHCard>
      </div>

      {/* Number pad */}
      <div style={{ padding:'18px 18px 0', display:'grid', gridTemplateColumns:'1fr 1fr 1fr', gap:8, position:'relative', zIndex:5 }}>
        {[1,2,3,4,5,6,7,8,9,'⌫',0,'OK'].map((k,i) => (
          <button key={i} style={{
            padding:'14px 0', borderRadius:18, border:'none',
            background: k === 'OK' ? DH.PINK : '#fff',
            color: k === 'OK' ? '#fff' : DH.PINK_DEEP,
            boxShadow: k === 'OK' ? `0 4px 0 ${DH.PINK_DEEP}` : `0 3px 0 ${DH.PINK_LIGHT}`,
            fontFamily:DH.font, fontWeight:800, fontSize:k === 'OK' ? 14 : 22,
            letterSpacing: k === 'OK' ? '0.1em' : 0,
          }}>{k}</button>
        ))}
      </div>

      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}
function MathChip({ n, hollow }) {
  return (
    <div style={{
      width:60, height:60, borderRadius:18, display:'flex', alignItems:'center', justifyContent:'center',
      background: hollow ? 'transparent' : DH.PINK_LIGHT,
      border: hollow ? `3px dashed ${DH.PINK_DEEP}` : `3px solid #fff`,
      boxShadow: hollow ? 'none' : `0 4px 0 ${DH.PINK}`,
      fontFamily:DH.font, fontWeight:800, fontSize:30, color:DH.PINK_DEEP,
    }}>{n}</div>
  );
}
window.DHParentMathIdle = DHParentMathIdle;
function DHParentMathWrong(){ return <DHParentMathIdle wrong/>; }
window.DHParentMathWrong = DHParentMathWrong;

// ────────────────────────────────────────────────────────────────────
// PARENTAL GATE — HOLD VARIANT (press & hold for 3s)
function DHParentHold() {
  return (
    <GPhone bg={DH.PINK_PAPER} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`linear-gradient(180deg, ${DH.PINK_LIGHT}, ${DH.PINK_PAPER} 60%)` }}/>
      <div style={{ position:'absolute', top:120, left:30, transform:'rotate(-18deg)', opacity:0.4 }}>
        <svg width="120" height="120" viewBox="0 0 24 24" fill={DH.PINK}><path d="M12 21S2 14 2 8a5 5 0 019-3 5 5 0 019 3c0 6-8 13-8 13z"/></svg>
      </div>
      <div style={{ position:'absolute', bottom:200, right:24, transform:'rotate(20deg)', opacity:0.4 }}>
        <svg width="140" height="140" viewBox="0 0 24 24" fill={DH.PINK_DEEP}><path d="M12 21S2 14 2 8a5 5 0 019-3 5 5 0 019 3c0 6-8 13-8 13z"/></svg>
      </div>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      <div style={{ padding:'4px 18px 0', display:'flex', alignItems:'center', justifyContent:'space-between', position:'relative', zIndex:5 }}>
        <button style={{ width:42, height:42, borderRadius:21, background:'#fff', border:'none', boxShadow:DH.shadow(DH.PINK), display:'flex', alignItems:'center', justifyContent:'center' }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="3" strokeLinecap="round"><path d="M6 6L18 18M18 6L6 18"/></svg>
        </button>
        <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:11, color:DH.PINK_DEEP, letterSpacing:'0.16em' }}>GROWN-UP CHECK</div>
        <div style={{ width:42 }}/>
      </div>

      {/* Title */}
      <div style={{ padding:'40px 28px 0', textAlign:'center', position:'relative', zIndex:5 }}>
        <div style={{ fontSize:46 }}>👆</div>
        <div style={{ marginTop:8, fontFamily:DH.font, fontWeight:700, fontSize:26, color:DH.PINK_DEEP, letterSpacing:'-0.02em', lineHeight:1.05 }}>
          Press & hold the heart
        </div>
        <div style={{ marginTop:10, fontFamily:DH.font, fontWeight:500, fontSize:14, color:'rgba(58,14,37,0.7)', lineHeight:1.45 }}>
          Hold the heart for <b>3 whole seconds</b> with one finger to confirm a grown-up is here.
        </div>
      </div>

      {/* Big heart with progress ring */}
      <div style={{ padding:'48px 0 0', display:'flex', justifyContent:'center', position:'relative', zIndex:5 }}>
        <div style={{ width:240, height:240, position:'relative' }}>
          {/* Progress ring */}
          <svg width="240" height="240" viewBox="0 0 240 240" style={{ position:'absolute', top:0, left:0 }}>
            <circle cx="120" cy="120" r="108" fill="none" stroke="#fff" strokeWidth="14"/>
            <circle cx="120" cy="120" r="108" fill="none" stroke={DH.PINK_DEEP} strokeWidth="14"
              strokeDasharray={2 * Math.PI * 108}
              strokeDashoffset={2 * Math.PI * 108 * (1 - 0.62)}
              strokeLinecap="round" transform="rotate(-90 120 120)"/>
          </svg>
          {/* Heart button */}
          <div style={{
            position:'absolute', inset:18, borderRadius:120,
            background:`radial-gradient(circle at 30% 30%, ${DH.PINK_LIGHT}, ${DH.PINK})`,
            border:`5px solid #fff`, boxShadow:`0 8px 0 ${DH.PINK_DEEP}, 0 14px 24px rgba(212,18,123,0.4)`,
            display:'flex', alignItems:'center', justifyContent:'center',
          }}>
            <svg width="100" height="100" viewBox="0 0 24 24" fill="#fff" stroke={DH.PINK_DEEP} strokeWidth="1.4">
              <path d="M12 21S2 14 2 8a5 5 0 019-3 5 5 0 019 3c0 6-8 13-8 13z"/>
            </svg>
          </div>
        </div>
      </div>

      {/* Counter */}
      <div style={{ padding:'24px 0 0', textAlign:'center', position:'relative', zIndex:5 }}>
        <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:11, color:DH.PINK_DEEP, opacity:0.6, letterSpacing:'0.16em' }}>HOLDING</div>
        <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:42, color:DH.PINK_DEEP, lineHeight:1, letterSpacing:'-0.02em' }}>1.8s</div>
      </div>

      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}
window.DHParentHold = DHParentHold;

// ────────────────────────────────────────────────────────────────────
// PAYWALL — single one-time unlock (sleek, justified)
function DHPaywall() {
  return (
    <GPhone bg={DH.PINK_DEEP} ringColor="rgba(58,14,37,0.4)">
      <div style={{ position:'absolute', inset:0, background:`linear-gradient(160deg, ${DH.PINK_DEEP} 0%, #9C2BFF 60%, #5A1099 100%)` }}/>
      {/* sparkle bg */}
      {[
        {t:120,l:30,s:18},{t:170,l:340,s:14},{t:240,l:60,s:22},{t:320,l:330,s:16},
        {t:480,l:40,s:14},{t:560,l:340,s:20},{t:640,l:80,s:16},
      ].map((s,i) => (
        <div key={i} style={{ position:'absolute', top:s.t, left:s.l, transform:`rotate(${i*23}deg)`, opacity:0.55 }}>
          <StickerSparkle size={s.s} fill="#fff"/>
        </div>
      ))}

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color="#fff"/></div>

      {/* Top close */}
      <div style={{ padding:'4px 18px 0', display:'flex', justifyContent:'space-between', alignItems:'center', position:'relative', zIndex:5 }}>
        <button style={{ width:42, height:42, borderRadius:21, background:'rgba(255,255,255,0.2)', border:'none', backdropFilter:'blur(6px)', display:'flex', alignItems:'center', justifyContent:'center' }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="3" strokeLinecap="round"><path d="M6 6L18 18M18 6L6 18"/></svg>
        </button>
        <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:11, color:'rgba(255,255,255,0.7)', letterSpacing:'0.12em' }}>RESTORE</div>
      </div>

      {/* Hero */}
      <div style={{ padding:'24px 24px 0', position:'relative', zIndex:5 }}>
        <div style={{ display:'flex', alignItems:'baseline', gap:6 }}>
          <span style={{ fontFamily:DH.font, fontWeight:700, fontSize:48, color:'#fff', letterSpacing:'-0.02em', lineHeight:0.9, textShadow:`0 4px 0 rgba(0,0,0,0.2)` }}>Unlock all of</span>
        </div>
        <div style={{ marginTop:6 }}>
          <GRWMLogo size={0.62} layout="stack" pink="#fff" deep="#5A1099"/>
        </div>
        <div style={{ marginTop:10, fontFamily:DH.font, fontWeight:500, fontSize:14, color:'rgba(255,255,255,0.85)', lineHeight:1.5, maxWidth:300 }}>
          One payment. Forever access. No subscriptions, no ads, no surprises.
        </div>
      </div>

      {/* Feature list */}
      <div style={{ padding:'20px 18px 0', position:'relative', zIndex:5 }}>
        <DHCard color="rgba(255,255,255,0.15)" deep="rgba(0,0,0,0.3)" br={22} pad={16} style={{ backdropFilter:'blur(8px)', border:`2px solid rgba(255,255,255,0.3)` }}>
          <div style={{ display:'flex', flexDirection:'column', gap:10 }}>
            {[
              { e:'💄', t:'62 pro shades', s:'Holographic, chrome, glittery, all unlocked' },
              { e:'✨', t:'All effects', s:'Disco, Mermaid, Galaxy, Doll, Chrome' },
              { e:'💼', t:'Unlimited locker', s:'Save as many looks as you dream up' },
              { e:'🎬', t:'1-min recording', s:'Up from 30 seconds. Make a real GRWM.' },
              { e:'🚫', t:'Zero ads', s:'Forever. Promise.' },
            ].map(f => (
              <div key={f.t} style={{ display:'flex', alignItems:'center', gap:10 }}>
                <div style={{
                  width:38, height:38, borderRadius:19, background:'rgba(255,255,255,0.95)',
                  display:'flex', alignItems:'center', justifyContent:'center', fontSize:20,
                  boxShadow:`0 3px 0 rgba(0,0,0,0.15)`,
                }}>{f.e}</div>
                <div style={{ flex:1 }}>
                  <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:14, color:'#fff', lineHeight:1 }}>{f.t}</div>
                  <div style={{ fontFamily:DH.font, fontWeight:500, fontSize:12, color:'rgba(255,255,255,0.75)', marginTop:2 }}>{f.s}</div>
                </div>
              </div>
            ))}
          </div>
        </DHCard>
      </div>

      {/* Price banner */}
      <div style={{ padding:'14px 18px 0', position:'relative', zIndex:5 }}>
        <div style={{
          padding:'10px 14px', borderRadius:14, background:DH.BUTTER,
          boxShadow:`0 3px 0 #C99B1F`,
          display:'flex', alignItems:'center', gap:8, justifyContent:'center',
        }}>
          <span style={{ fontFamily:DH.font, fontWeight:800, fontSize:11, color:DH.INK, letterSpacing:'0.1em' }}>🎁 LAUNCH PRICE — SAVE $5</span>
        </div>
      </div>

      {/* CTA */}
      <div style={{ position:'absolute', bottom:46, left:18, right:18, display:'flex', flexDirection:'column', gap:8, zIndex:5 }}>
        <DHButton kind="primary" size="xl" style={{
          width:'100%', background:`linear-gradient(180deg, ${DH.BUTTER}, #E8A91D)`,
          boxShadow:`0 5px 0 #C99B1F, 0 8px 16px rgba(0,0,0,0.3), inset 0 2px 0 rgba(255,255,255,0.5)`, color:DH.INK,
        }}>
          Unlock for $14.99 ✨
        </DHButton>
        <div style={{ textAlign:'center', fontFamily:DH.font, fontWeight:600, fontSize:11, color:'rgba(255,255,255,0.7)' }}>
          Grown-up check first · One-time payment · No subscription
        </div>
      </div>

      <GHomeIndicator color="rgba(255,255,255,0.5)"/>
    </GPhone>
  );
}
window.DHPaywall = DHPaywall;

// ────────────────────────────────────────────────────────────────────
// SETTINGS — grouped lists
function DHSettings() {
  return (
    <GPhone bg={DH.CREAM} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`linear-gradient(180deg, ${DH.PINK_PAPER}, ${DH.CREAM} 30%)` }}/>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      <div style={{ padding:'4px 18px 0', display:'flex', alignItems:'center', justifyContent:'space-between', position:'relative', zIndex:5 }}>
        <button style={{ width:42, height:42, borderRadius:21, background:'#fff', border:'none', boxShadow:DH.shadow(DH.PINK), display:'flex', alignItems:'center', justifyContent:'center' }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="3" strokeLinecap="round"><path d="M15 6l-6 6 6 6"/></svg>
        </button>
        <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:18, color:DH.PINK_DEEP }}>Settings</div>
        <div style={{ width:42 }}/>
      </div>

      <div style={{ padding:'14px 18px 130px', position:'relative', zIndex:5, display:'flex', flexDirection:'column', gap:14 }}>
        {/* Account */}
        <SettingsGroup title="ACCOUNT">
          <SettingsRow icon="👧" iconBg={DH.PINK} label="Stella" sub="@stellaglow" right={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="2.6" strokeLinecap="round"><path d="M9 6l6 6-6 6"/></svg>}/>
          <SettingsRow icon="👋" iconBg={DH.LAV} label="Grown-up email" sub="mom@grwmstudio.com" right={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="2.6" strokeLinecap="round"><path d="M9 6l6 6-6 6"/></svg>}/>
          <SettingsRow icon="✨" iconBg={DH.BUTTER} label="Studio Pro" sub="Unlocked · forever" right={<span style={{ fontSize:18 }}>👑</span>}/>
        </SettingsGroup>

        {/* Privacy */}
        <SettingsGroup title="PRIVACY & SAFETY">
          <SettingsRow icon="📷" iconBg="#FF8AB8" label="Camera" sub="On" right={<Toggle on/>}/>
          <SettingsRow icon="🎙️" iconBg="#FFB46B" label="Microphone" sub="On" right={<Toggle on/>}/>
          <SettingsRow icon="📂" iconBg={DH.MINT} label="Save to Photos" sub="Off" right={<Toggle/>}/>
          <SettingsRow icon="🚫" iconBg="#C8C8FF" label="Block share extensions" sub="Stays inside GRWM" right={<Toggle on/>}/>
        </SettingsGroup>

        {/* Look & feel */}
        <SettingsGroup title="LOOK & FEEL">
          <SettingsRow icon="🎀" iconBg={DH.PINK_LIGHT} label="Theme" sub="Bubblegum Plastic" right={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="2.6" strokeLinecap="round"><path d="M9 6l6 6-6 6"/></svg>}/>
          <SettingsRow icon="🔊" iconBg="#7AE8E0" label="Sounds & haptics" sub="Sparkly" right={<Toggle on/>}/>
        </SettingsGroup>

        {/* About */}
        <SettingsGroup title="ABOUT">
          <SettingsRow icon="❓" iconBg={DH.MINT} label="Help center" right={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="2.6" strokeLinecap="round"><path d="M9 6l6 6-6 6"/></svg>}/>
          <SettingsRow icon="📜" iconBg={DH.BUTTER} label="Privacy policy" right={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="2.6" strokeLinecap="round"><path d="M9 6l6 6-6 6"/></svg>}/>
          <SettingsRow icon="ℹ️" iconBg="#C8C8FF" label="Version" sub="2.1.0 · Build 408"/>
        </SettingsGroup>

        {/* Sign out */}
        <DHButton kind="white" size="lg" style={{ width:'100%', color:'#FF2D5A' }}>Sign out grown-up</DHButton>
      </div>

      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}
function SettingsGroup({ title, children }) {
  return (
    <div>
      <div style={{ padding:'0 6px 6px', fontFamily:DH.font, fontWeight:800, fontSize:10, color:DH.PINK_DEEP, opacity:0.6, letterSpacing:'0.16em' }}>{title}</div>
      <DHCard color="#fff" deep={DH.PINK_LIGHT} br={20} pad={0} style={{ overflow:'hidden' }}>
        {React.Children.map(children, (c, i) => (
          <div style={{ borderTop: i === 0 ? 'none' : `1px solid ${DH.PINK_PAPER}` }}>{c}</div>
        ))}
      </DHCard>
    </div>
  );
}
function SettingsRow({ icon, iconBg, label, sub, right }) {
  return (
    <div style={{ padding:'10px 12px', display:'flex', alignItems:'center', gap:10 }}>
      <div style={{
        width:36, height:36, borderRadius:11, background:iconBg,
        display:'flex', alignItems:'center', justifyContent:'center', fontSize:18,
        boxShadow:`0 2px 0 rgba(0,0,0,0.08), inset 0 -2px 0 rgba(0,0,0,0.08), inset 0 2px 0 rgba(255,255,255,0.4)`,
      }}>{icon}</div>
      <div style={{ flex:1 }}>
        <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:14, color:DH.INK, lineHeight:1.1 }}>{label}</div>
        {sub && <div style={{ fontFamily:DH.font, fontWeight:500, fontSize:11, color:'rgba(58,14,37,0.55)', marginTop:2 }}>{sub}</div>}
      </div>
      {right}
    </div>
  );
}
function Toggle({ on }) {
  return (
    <div style={{
      width:40, height:24, borderRadius:12, padding:2,
      background: on ? DH.PINK : 'rgba(58,14,37,0.15)',
      boxShadow: on ? `inset 0 2px 0 ${DH.PINK_DEEP}` : 'none',
    }}>
      <div style={{ width:20, height:20, borderRadius:10, background:'#fff', marginLeft: on ? 16 : 0, boxShadow:'0 1px 3px rgba(0,0,0,0.2)' }}/>
    </div>
  );
}
window.DHSettings = DHSettings;
