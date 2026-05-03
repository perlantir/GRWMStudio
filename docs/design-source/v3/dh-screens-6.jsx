// GRWM Studio — Mirror state variants + Onboarding extras
// Mirror states: Countdown, Recording, Pro-Gate (locked premium shade)
// Onboarding extras: Parent Info, Permissions Denied

// ────────────────────────────────────────────────────────────────────
// PARENT INFO — collected before camera ask, friendly + low-fidelity copy
function DHParentInfo() {
  return (
    <GPhone bg={DH.PINK_PAPER} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`repeating-linear-gradient(45deg, ${DH.PINK_PAPER} 0 30px, ${DH.CREAM} 30px 32px)`, opacity:0.7 }}/>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      <div style={{ padding:'4px 18px 0', display:'flex', alignItems:'center', justifyContent:'space-between', position:'relative', zIndex:5 }}>
        <button style={{ width:42, height:42, borderRadius:21, background:'#fff', border:'none', cursor:'pointer', boxShadow:DH.shadow(DH.PINK), display:'flex', alignItems:'center', justifyContent:'center' }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="3" strokeLinecap="round"><path d="M15 6l-6 6 6 6"/></svg>
        </button>
        <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:11, color:DH.PINK_DEEP, letterSpacing:'0.16em' }}>STEP 1 OF 3</div>
        <div style={{ width:42 }}/>
      </div>

      {/* hero card */}
      <div style={{ padding:'14px 18px 0', position:'relative', zIndex:5 }}>
        <DHCard color="#fff" deep={DH.PINK} br={28} pad={20}>
          <div style={{ display:'flex', alignItems:'center', gap:10 }}>
            <div style={{ fontSize:42 }}>👋</div>
            <div>
              <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:11, color:'rgba(58,14,37,0.5)', letterSpacing:'0.16em' }}>HI, GROWN-UP</div>
              <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:22, color:DH.PINK_DEEP, lineHeight:1, marginTop:2 }}>A quick check-in</div>
            </div>
          </div>
          <div style={{ marginTop:10, fontFamily:DH.font, fontWeight:500, fontSize:13.5, color:'rgba(58,14,37,0.75)', lineHeight:1.45 }}>
            We need a parent or guardian's email to keep things safe. Nothing posts publicly. Photos stay on this device.
          </div>
        </DHCard>
      </div>

      {/* form card */}
      <div style={{ padding:'14px 18px 0', position:'relative', zIndex:5 }}>
        <DHCard color={DH.CREAM} deep={DH.PINK_LIGHT} br={24} pad={16}>
          {/* Email */}
          <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:11, color:DH.PINK_DEEP, letterSpacing:'0.12em' }}>GROWN-UP'S EMAIL</div>
          <div style={{
            marginTop:6, padding:'12px 14px', borderRadius:16, background:'#fff',
            border:`2.5px solid ${DH.PINK}`, boxShadow:`0 3px 0 ${DH.PINK}`,
            display:'flex', alignItems:'center', gap:8,
          }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="2.4" strokeLinecap="round"><rect x="3" y="5" width="18" height="14" rx="3"/><path d="M3 7l9 6 9-6"/></svg>
            <span style={{ flex:1, fontFamily:DH.font, fontWeight:600, fontSize:14, color:DH.INK }}>mom@grwmstudio.com</span>
          </div>

          {/* Kid age */}
          <div style={{ marginTop:14, fontFamily:DH.font, fontWeight:700, fontSize:11, color:DH.PINK_DEEP, letterSpacing:'0.12em' }}>HOW OLD IS YOUR KID?</div>
          <div style={{ marginTop:6, display:'grid', gridTemplateColumns:'repeat(4, 1fr)', gap:6 }}>
            {['6–7','8–9','10–11','12+'].map((a,i) => (
              <div key={a} style={{
                padding:'10px 0', borderRadius:14, textAlign:'center',
                background: i===1 ? DH.PINK : '#fff',
                color: i===1 ? '#fff' : DH.PINK_DEEP,
                boxShadow: i===1 ? `0 3px 0 ${DH.PINK_DEEP}` : `0 2px 0 ${DH.PINK_LIGHT}`,
                fontFamily:DH.font, fontWeight:800, fontSize:13,
              }}>{a}</div>
            ))}
          </div>

          {/* Toggle row */}
          <div style={{ marginTop:14, padding:'12px 14px', borderRadius:16, background:'#fff', boxShadow:`0 2px 0 ${DH.PINK_LIGHT}`, display:'flex', alignItems:'center', gap:10 }}>
            <div style={{ flex:1 }}>
              <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:13, color:DH.INK }}>Email me weekly recap</div>
              <div style={{ fontFamily:DH.font, fontWeight:500, fontSize:11, color:'rgba(58,14,37,0.55)' }}>See looks your kid saved</div>
            </div>
            <div style={{ width:44, height:26, borderRadius:13, background:DH.PINK, padding:2, boxShadow:`inset 0 2px 0 ${DH.PINK_DEEP}` }}>
              <div style={{ width:22, height:22, borderRadius:11, background:'#fff', marginLeft:18, boxShadow:'0 2px 4px rgba(0,0,0,0.2)' }}/>
            </div>
          </div>
        </DHCard>
      </div>

      {/* Disclaimers */}
      <div style={{ padding:'14px 24px 0', position:'relative', zIndex:5 }}>
        <div style={{ fontFamily:DH.font, fontWeight:500, fontSize:11, color:'rgba(58,14,37,0.55)', lineHeight:1.5 }}>
          By continuing, you agree GRWM may store your email to send recaps and recovery links. <span style={{ color:DH.PINK_DEEP, textDecoration:'underline', fontWeight:700 }}>Privacy</span> · <span style={{ color:DH.PINK_DEEP, textDecoration:'underline', fontWeight:700 }}>Parent terms</span>
        </div>
      </div>

      <div style={{ position:'absolute', bottom:46, left:18, right:18, zIndex:5 }}>
        <DHButton kind="primary" size="xl" style={{ width:'100%' }}
          iconRight={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.8" strokeLinecap="round"><path d="M5 12h14M13 5l7 7-7 7"/></svg>}>
          Continue
        </DHButton>
      </div>

      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}
window.DHParentInfo = DHParentInfo;

// ────────────────────────────────────────────────────────────────────
// PERMISSIONS DENIED — friendly recovery state
function DHPermissionsDenied() {
  return (
    <GPhone bg={DH.CREAM} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`linear-gradient(180deg, ${DH.PINK_PAPER}, ${DH.CREAM} 50%)` }}/>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      <div style={{ padding:'4px 18px 0', display:'flex', alignItems:'center', position:'relative', zIndex:5 }}>
        <button style={{ width:42, height:42, borderRadius:21, background:'#fff', border:'none', cursor:'pointer', boxShadow:DH.shadow(DH.PINK), display:'flex', alignItems:'center', justifyContent:'center' }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="3" strokeLinecap="round"><path d="M15 6l-6 6 6 6"/></svg>
        </button>
      </div>

      {/* hero illustration */}
      <div style={{ padding:'24px 18px 0', position:'relative', zIndex:5, display:'flex', justifyContent:'center' }}>
        <div style={{
          width:200, height:200, borderRadius:100,
          background:`radial-gradient(circle at 30% 30%, ${DH.PINK_LIGHT}, ${DH.PINK})`,
          border:`6px solid #fff`, boxShadow:`0 8px 0 ${DH.PINK_DEEP}, 0 14px 24px rgba(212,18,123,0.3)`,
          display:'flex', alignItems:'center', justifyContent:'center', position:'relative',
        }}>
          <div style={{ fontSize:96, transform:'translateY(-4px)' }}>📷</div>
          {/* lock badge */}
          <div style={{
            position:'absolute', bottom:-6, right:-6, width:64, height:64, borderRadius:32,
            background:'#fff', border:`5px solid ${DH.PINK_DEEP}`,
            display:'flex', alignItems:'center', justifyContent:'center',
            boxShadow:`0 5px 0 ${DH.PINK_DEEP}`,
          }}>
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round">
              <rect x="5" y="11" width="14" height="10" rx="2"/>
              <path d="M8 11V7a4 4 0 018 0v4"/>
            </svg>
          </div>
          <div style={{ position:'absolute', top:14, left:18, transform:'rotate(-12deg)' }}><StickerSparkle size={20} fill="#fff"/></div>
          <div style={{ position:'absolute', bottom:30, left:0, transform:'rotate(20deg)' }}><StickerSparkle size={16} fill={DH.BUTTER}/></div>
        </div>
      </div>

      {/* copy */}
      <div style={{ padding:'24px 28px 0', textAlign:'center', position:'relative', zIndex:5 }}>
        <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:28, color:DH.INK, letterSpacing:'-0.02em', lineHeight:1.05 }}>
          The mirror needs the camera 💕
        </div>
        <div style={{ marginTop:10, fontFamily:DH.font, fontWeight:500, fontSize:14.5, color:'rgba(58,14,37,0.7)', lineHeight:1.5 }}>
          Without it, the makeup can't land on your face. Tap below to open Settings → GRWM, then turn on <b>Camera</b>.
        </div>
      </div>

      {/* steps card */}
      <div style={{ padding:'18px 18px 0', position:'relative', zIndex:5 }}>
        <DHCard color="#fff" deep={DH.PINK_LIGHT} br={20} pad={14}>
          <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:11, color:DH.PINK_DEEP, letterSpacing:'0.12em' }}>HOW TO TURN IT ON</div>
          <div style={{ marginTop:10, display:'flex', flexDirection:'column', gap:8 }}>
            {[
              { n:1, t:'Tap "Open Settings" below' },
              { n:2, t:'Find Camera in the list' },
              { n:3, t:'Switch it on. Come back here.' },
            ].map(s => (
              <div key={s.n} style={{ display:'flex', alignItems:'center', gap:10 }}>
                <div style={{
                  width:26, height:26, borderRadius:13, background:DH.PINK,
                  boxShadow:`0 2px 0 ${DH.PINK_DEEP}`, color:'#fff',
                  display:'flex', alignItems:'center', justifyContent:'center',
                  fontFamily:DH.font, fontWeight:800, fontSize:12,
                }}>{s.n}</div>
                <span style={{ fontFamily:DH.font, fontWeight:600, fontSize:13, color:DH.INK }}>{s.t}</span>
              </div>
            ))}
          </div>
        </DHCard>
      </div>

      <div style={{ position:'absolute', bottom:46, left:18, right:18, display:'flex', flexDirection:'column', gap:8, zIndex:5 }}>
        <DHButton kind="primary" size="xl" style={{ width:'100%' }}
          icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.6"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 00.3 1.8l.1.1a2 2 0 11-2.8 2.8l-.1-.1a1.7 1.7 0 00-1.8-.3 1.7 1.7 0 00-1 1.5V21a2 2 0 11-4 0v-.1a1.7 1.7 0 00-1.1-1.5 1.7 1.7 0 00-1.8.3l-.1.1a2 2 0 11-2.8-2.8l.1-.1a1.7 1.7 0 00.3-1.8 1.7 1.7 0 00-1.5-1H3a2 2 0 110-4h.1a1.7 1.7 0 001.5-1.1 1.7 1.7 0 00-.3-1.8l-.1-.1a2 2 0 112.8-2.8l.1.1a1.7 1.7 0 001.8.3h0a1.7 1.7 0 001-1.5V3a2 2 0 114 0v.1a1.7 1.7 0 001 1.5 1.7 1.7 0 001.8-.3l.1-.1a2 2 0 112.8 2.8l-.1.1a1.7 1.7 0 00-.3 1.8v0a1.7 1.7 0 001.5 1H21a2 2 0 110 4h-.1a1.7 1.7 0 00-1.5 1z"/></svg>}>
          Open Settings
        </DHButton>
        <DHButton kind="ghost" size="md" style={{ width:'100%' }}>Skip — browse looks instead</DHButton>
      </div>

      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}
window.DHPermissionsDenied = DHPermissionsDenied;

// ────────────────────────────────────────────────────────────────────
// MIRROR — COUNTDOWN STATE (3..2..1 before record)
function DHMirrorCountdown() {
  return (
    <GPhone bg={DH.PINK_PAPER} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`repeating-linear-gradient(45deg, ${DH.PINK_PAPER} 0 24px, ${DH.CREAM} 24px 48px)`, opacity:0.7 }}/>
      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      {/* Mirror viewport */}
      <div style={{ position:'relative', margin:'72px 18px 0', padding:10, borderRadius:36,
        background:`linear-gradient(180deg, ${DH.PINK} 0%, ${DH.PINK_DEEP} 100%)`,
        boxShadow:`0 6px 0 ${DH.PINK_DEEP}, 0 14px 28px rgba(212,18,123,0.4)`,
      }}>
        <div style={{ position:'relative', borderRadius:28, overflow:'hidden', height:560,
          background:`radial-gradient(ellipse at center, #FFE0EE 0%, #FFB3D9 100%)`, border:`3px solid #fff`,
        }}>
          {/* Dimmer */}
          <div style={{ position:'absolute', inset:0, background:'rgba(212,18,123,0.4)' }}/>
          {/* face peek */}
          <div style={{ position:'absolute', bottom:0, left:'50%', transform:'translateX(-50%)', opacity:0.7 }}>
            <FaceMock skin="#FFD4B8" lipColor={DH.PINK} blushColor={DH.PINK} eyeShadow={DH.LAV} smile size={1.05}/>
          </div>

          {/* Big 3 */}
          <div style={{ position:'absolute', inset:0, display:'flex', alignItems:'center', justifyContent:'center' }}>
            <div style={{
              width:200, height:200, borderRadius:100, background:'#fff',
              border:`8px solid ${DH.PINK_DEEP}`,
              boxShadow:`0 10px 0 ${DH.PINK_DEEP}, 0 20px 40px rgba(212,18,123,0.5)`,
              display:'flex', alignItems:'center', justifyContent:'center',
              position:'relative',
            }}>
              <div style={{
                fontFamily:DH.font, fontWeight:700, fontSize:140, color:DH.PINK,
                lineHeight:0.85, textShadow:`0 6px 0 ${DH.PINK_DEEP}`,
                WebkitTextStroke:`3px #fff`, paintOrder:'stroke fill',
              }}>3</div>
              <div style={{ position:'absolute', top:-12, right:-8 }}><StickerSparkle size={28} fill={DH.BUTTER}/></div>
              <div style={{ position:'absolute', bottom:-4, left:-8, transform:'rotate(180deg)' }}><StickerSparkle size={22} fill={DH.LAV}/></div>
            </div>
          </div>

          {/* corner — recording about to start */}
          <div style={{ position:'absolute', top:14, left:14, padding:'6px 12px', borderRadius:99, background:DH.PINK_DEEP, display:'flex', alignItems:'center', gap:6, fontFamily:DH.font, fontWeight:800, fontSize:11, color:'#fff', letterSpacing:'0.1em' }}>
            <span style={{ width:8, height:8, borderRadius:4, background:'#fff' }}/>
            GET READY
          </div>

          {/* tap to cancel */}
          <div style={{ position:'absolute', bottom:24, left:0, right:0, textAlign:'center' }}>
            <div style={{ display:'inline-block', padding:'8px 16px', borderRadius:99, background:'rgba(255,255,255,0.85)', backdropFilter:'blur(6px)', fontFamily:DH.font, fontWeight:700, fontSize:12, color:DH.PINK_DEEP }}>
              Tap anywhere to cancel
            </div>
          </div>
        </div>
      </div>

      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}
window.DHMirrorCountdown = DHMirrorCountdown;

// ────────────────────────────────────────────────────────────────────
// MIRROR — RECORDING STATE (timer top, big stop button, REC pill)
function DHMirrorRecording() {
  return (
    <GPhone bg={DH.PINK_PAPER} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`repeating-linear-gradient(45deg, ${DH.PINK_PAPER} 0 24px, ${DH.CREAM} 24px 48px)`, opacity:0.7 }}/>
      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      {/* Top — REC pill */}
      <div style={{ padding:'4px 18px 0', display:'flex', alignItems:'center', justifyContent:'space-between', position:'relative', zIndex:5 }}>
        <div style={{
          padding:'8px 14px', borderRadius:99, background:'#FF2D5A', color:'#fff',
          boxShadow:`0 4px 0 #B41540`, fontFamily:DH.font, fontWeight:800, fontSize:12,
          display:'flex', alignItems:'center', gap:7, letterSpacing:'0.08em',
        }}>
          <span style={{ width:9, height:9, borderRadius:5, background:'#fff', boxShadow:'0 0 0 3px rgba(255,255,255,0.4)' }}/>
          REC · 0:14
        </div>
        <div style={{
          padding:'8px 12px', borderRadius:99, background:'#fff',
          boxShadow:`0 3px 0 ${DH.PINK_LIGHT}`, fontFamily:DH.font, fontWeight:700, fontSize:11, color:DH.PINK_DEEP,
          display:'flex', alignItems:'center', gap:6,
        }}>
          ⏱ 0:46 left
        </div>
      </div>

      {/* Mirror viewport */}
      <div style={{ position:'relative', margin:'14px 18px 0', padding:10, borderRadius:36,
        background:`linear-gradient(180deg, ${DH.PINK} 0%, ${DH.PINK_DEEP} 100%)`,
        boxShadow:`0 6px 0 ${DH.PINK_DEEP}, 0 14px 28px rgba(212,18,123,0.4)`,
      }}>
        <div style={{ position:'relative', borderRadius:28, overflow:'hidden', height:520,
          background:`radial-gradient(ellipse at center, #FFE0EE 0%, #FFB3D9 100%)`, border:`5px solid #FF2D5A`,
        }}>
          <div style={{ position:'absolute', bottom:0, left:'50%', transform:'translateX(-50%)' }}>
            <FaceMock skin="#FFD4B8" lipColor={DH.PINK_DEEP} lipShine="#FFE5F2" blushColor={DH.PINK} blushOpacity={0.6} eyeShadow={DH.LAV} eyeShadowOpacity={0.55} smile size={1.05}/>
          </div>

          {/* Audio levels strip — bottom */}
          <div style={{ position:'absolute', bottom:14, left:14, right:14, padding:'8px 14px', borderRadius:18, background:'rgba(255,255,255,0.85)', backdropFilter:'blur(6px)', display:'flex', alignItems:'center', gap:8 }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="2.4" strokeLinecap="round"><rect x="9" y="3" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0014 0M12 18v3"/></svg>
            <div style={{ display:'flex', gap:2, flex:1, alignItems:'center' }}>
              {[12, 18, 28, 22, 30, 14, 24, 32, 20, 28, 14, 22, 26, 18, 12, 22, 18, 14, 20, 16, 12, 18, 24, 30, 22].map((h, i) => (
                <div key={i} style={{ flex:1, height:h, borderRadius:1.5, background: i < 13 ? DH.PINK_DEEP : 'rgba(212,18,123,0.25)' }}/>
              ))}
            </div>
            <span style={{ fontFamily:DH.font, fontWeight:800, fontSize:11, color:DH.PINK_DEEP }}>0:14</span>
          </div>

          {/* corner sparkles */}
          <div style={{ position:'absolute', top:30, left:30 }}><StickerSparkle size={22} fill="#fff"/></div>
          <div style={{ position:'absolute', top:80, right:36 }}><StickerSparkle size={14} fill={DH.BUTTER}/></div>
        </div>
      </div>

      {/* Bottom — STOP button (big) */}
      <div style={{ position:'absolute', bottom:0, left:0, right:0, padding:'14px 18px 32px', display:'flex', alignItems:'center', justifyContent:'center', gap:14, zIndex:5 }}>
        <button style={{
          width:54, height:54, borderRadius:27, background:'#fff', border:'none',
          boxShadow:`0 4px 0 ${DH.PINK}`, display:'flex', alignItems:'center', justifyContent:'center',
        }}>
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="2.6"><circle cx="12" cy="12" r="3"/></svg>
        </button>
        <button style={{
          width:88, height:88, borderRadius:44, background:'#FF2D5A', border:`6px solid #fff`,
          boxShadow:`0 7px 0 #B41540, 0 12px 24px rgba(255,45,90,0.5)`,
          display:'flex', alignItems:'center', justifyContent:'center', position:'relative',
        }}>
          <div style={{ width:32, height:32, borderRadius:6, background:'#fff' }}/>
        </button>
        <button style={{
          width:54, height:54, borderRadius:27, background:'#fff', border:'none',
          boxShadow:`0 4px 0 ${DH.PINK}`, display:'flex', alignItems:'center', justifyContent:'center',
        }}>
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="2.4" strokeLinecap="round"><path d="M9 6L3 12l6 6"/><path d="M21 6l-6 6 6 6"/></svg>
        </button>
      </div>

      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}
window.DHMirrorRecording = DHMirrorRecording;

// ────────────────────────────────────────────────────────────────────
// MIRROR — PRO/PREMIUM GATE STATE (locked shade asks for upgrade)
function DHMirrorProGate() {
  return (
    <GPhone bg={DH.PINK_PAPER} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`repeating-linear-gradient(45deg, ${DH.PINK_PAPER} 0 24px, ${DH.CREAM} 24px 48px)`, opacity:0.7 }}/>
      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      {/* Mirror viewport — dimmed */}
      <div style={{ position:'relative', margin:'14px 18px 0', padding:10, borderRadius:36,
        background:`linear-gradient(180deg, ${DH.PINK} 0%, ${DH.PINK_DEEP} 100%)`,
        boxShadow:`0 6px 0 ${DH.PINK_DEEP}, 0 14px 28px rgba(212,18,123,0.4)`,
      }}>
        <div style={{ position:'relative', borderRadius:28, overflow:'hidden', height:380,
          background:`radial-gradient(ellipse at center, #FFE0EE 0%, #FFB3D9 100%)`, border:`3px solid #fff`,
        }}>
          <div style={{ position:'absolute', bottom:0, left:'50%', transform:'translateX(-50%)', opacity:0.4 }}>
            <FaceMock skin="#FFD4B8" lipColor={DH.PINK} blushColor={DH.PINK} eyeShadow={DH.LAV} smile size={1.05}/>
          </div>
          <div style={{ position:'absolute', inset:0, background:'rgba(58,14,37,0.45)', backdropFilter:'blur(2px)' }}/>

          {/* Locked sticker */}
          <div style={{ position:'absolute', inset:0, display:'flex', alignItems:'center', justifyContent:'center', flexDirection:'column' }}>
            <div style={{
              width:96, height:96, borderRadius:48, background:DH.BUTTER,
              border:`5px solid #fff`, boxShadow:`0 6px 0 #C99B1F, 0 10px 20px rgba(0,0,0,0.3)`,
              display:'flex', alignItems:'center', justifyContent:'center',
            }}>
              <svg width="44" height="44" viewBox="0 0 24 24" fill="none" stroke={DH.INK} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round">
                <rect x="5" y="11" width="14" height="10" rx="2"/>
                <path d="M8 11V7a4 4 0 018 0v4"/>
              </svg>
            </div>
            <div style={{
              marginTop:14, padding:'8px 14px', borderRadius:99, background:'#fff',
              boxShadow:`0 4px 0 ${DH.BUTTER}`,
              fontFamily:DH.font, fontWeight:800, fontSize:12, letterSpacing:'0.12em', color:DH.INK,
            }}>✦ STUDIO EXCLUSIVE ✦</div>
          </div>
        </div>
      </div>

      {/* Below — pro shade pitch */}
      <div style={{ padding:'14px 18px 0' }}>
        <DHCard color="#fff" deep={DH.BUTTER} br={22} pad={16}>
          <div style={{ display:'flex', gap:12, alignItems:'center' }}>
            <div style={{
              width:54, height:54, borderRadius:27,
              background:`conic-gradient(from 0deg, ${DH.PINK_DEEP}, #9C2BFF, ${DH.PINK}, ${DH.PINK_DEEP})`,
              border:`3px solid #fff`, boxShadow:`0 3px 0 ${DH.PINK_DEEP}`,
            }}/>
            <div style={{ flex:1 }}>
              <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:9, letterSpacing:'0.32em', color:'#C99B1F' }}>PRO SHADE № 023</div>
              <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:20, color:DH.PINK_DEEP, lineHeight:1 }}>Disco Brat ✨</div>
              <div style={{ marginTop:2, fontFamily:DH.font, fontWeight:600, fontSize:11, color:'rgba(58,14,37,0.6)' }}>Holographic chrome · violet shift</div>
            </div>
          </div>
          <div style={{ marginTop:12, display:'flex', alignItems:'center', gap:8, padding:'10px 12px', borderRadius:14, background:DH.PINK_PAPER }}>
            <span style={{ fontSize:18 }}>🎁</span>
            <span style={{ fontFamily:DH.font, fontWeight:600, fontSize:12, color:DH.INK }}>+ <b>62 more</b> pro shades, looks & filters</span>
          </div>
        </DHCard>
      </div>

      <div style={{ position:'absolute', bottom:46, left:18, right:18, display:'flex', flexDirection:'column', gap:8, zIndex:5 }}>
        <DHButton kind="primary" size="xl" style={{ width:'100%', background:`linear-gradient(180deg, ${DH.BUTTER}, #E8A91D)`, boxShadow:`0 5px 0 #C99B1F, inset 0 2px 0 rgba(255,255,255,0.5)`, color:DH.INK }}
          icon={<span style={{ fontSize:18 }}>✨</span>}>
          Unlock everything · $14.99
        </DHButton>
        <DHButton kind="ghost" size="md" style={{ width:'100%' }}>Maybe later</DHButton>
      </div>

      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}
window.DHMirrorProGate = DHMirrorProGate;
