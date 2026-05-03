// GRWM Studio — Permissions screen
// Asks for camera + photos in a friendly, plastic-toy way

function DHPermissions() {
  return (
    <GPhone bg={DH.CREAM} ringColor="rgba(212,18,123,0.25)">
      {/* striped wallpaper bottom */}
      <div style={{ position:'absolute', inset:0, background:`linear-gradient(180deg, ${DH.CREAM} 60%, ${DH.PINK_PAPER} 100%)` }}/>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      {/* back */}
      <div style={{ padding:'4px 18px 0', display:'flex', alignItems:'center', justifyContent:'space-between', position:'relative', zIndex:5 }}>
        <button style={{
          width:42, height:42, borderRadius:21, background:'#fff', border:'none', cursor:'pointer',
          boxShadow: DH.shadow(DH.PINK), display:'flex', alignItems:'center', justifyContent:'center',
        }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="3" strokeLinecap="round"><path d="M15 18l-6-6 6-6"/></svg>
        </button>
        <div style={{ display:'flex', gap:6 }}>
          <span style={{ width:8, height:8, borderRadius:4, background:'rgba(212,18,123,0.25)' }}/>
          <span style={{ width:24, height:8, borderRadius:4, background:DH.PINK_DEEP, boxShadow:`0 2px 0 ${DH.INK}` }}/>
          <span style={{ width:8, height:8, borderRadius:4, background:'rgba(212,18,123,0.25)' }}/>
        </div>
        <div style={{ width:42 }}/>
      </div>

      {/* Hero camera card */}
      <div style={{ padding:'22px 22px 0', position:'relative', zIndex:5 }}>
        <DHCard color={DH.PINK} deep={DH.PINK_DEEP} br={32} pad={0} style={{ height:240, position:'relative', overflow:'hidden' }}>
          {/* sparkle wallpaper */}
          <div style={{ position:'absolute', inset:0, background:`radial-gradient(circle at 30% 20%, rgba(255,255,255,0.4), transparent 40%), radial-gradient(circle at 75% 70%, rgba(255,214,107,0.4), transparent 40%)` }}/>
          {/* big plastic camera icon */}
          <div style={{ position:'absolute', inset:0, display:'flex', alignItems:'center', justifyContent:'center' }}>
            <div style={{ width:160, height:130, position:'relative' }}>
              {/* camera body */}
              <div style={{
                position:'absolute', inset:0, background:'#fff', borderRadius:24,
                boxShadow:`0 6px 0 ${DH.PINK_DEEP}, inset 0 -8px 0 rgba(255,184,220,0.6)`,
              }}/>
              {/* top bump */}
              <div style={{
                position:'absolute', top:-14, left:48, width:64, height:24, background:'#fff', borderRadius:12,
                boxShadow:`0 4px 0 ${DH.PINK_DEEP}`,
              }}/>
              {/* lens */}
              <div style={{
                position:'absolute', top:24, left:32, width:96, height:96, borderRadius:48,
                background:`radial-gradient(circle at 35% 30%, ${DH.PINK_LIGHT}, ${DH.PINK_DEEP} 80%)`,
                boxShadow:`inset 0 -6px 0 rgba(0,0,0,0.2), inset 0 4px 8px rgba(255,255,255,0.5)`,
                border:`4px solid #fff`,
              }}>
                <div style={{ position:'absolute', top:14, left:18, width:18, height:18, borderRadius:9, background:'rgba(255,255,255,0.7)' }}/>
              </div>
              {/* flash dot */}
              <div style={{ position:'absolute', top:8, right:14, width:14, height:14, borderRadius:7, background:DH.BUTTER, boxShadow:`0 2px 0 #C99B1F` }}/>
              {/* sparkles */}
              <div style={{ position:'absolute', top:-22, right:-20, transform:'rotate(15deg)' }}><StickerSparkle size={28} fill="#fff"/></div>
              <div style={{ position:'absolute', bottom:-10, left:-20 }}><StickerSparkle size={22} fill={DH.BUTTER}/></div>
            </div>
          </div>
        </DHCard>
      </div>

      {/* Headline */}
      <div style={{ padding:'24px 24px 0', textAlign:'center', position:'relative', zIndex:5 }}>
        <div style={{
          fontFamily: DH.font, fontWeight: 700, fontSize: 32, lineHeight: 0.95, color: DH.PINK_DEEP, letterSpacing:'-0.02em',
        }}>One quick&nbsp;thing!</div>
        <div style={{
          marginTop:10, fontFamily:DH.font, fontWeight:500, fontSize:14, color: DH.INK, opacity: 0.7, lineHeight:1.45, maxWidth:300, marginLeft:'auto', marginRight:'auto',
        }}>We need a few permissions so the magic mirror can do its thing. We never store anything without you tapping save.</div>
      </div>

      {/* Permission rows */}
      <div style={{ padding:'18px 18px 0', display:'flex', flexDirection:'column', gap:10, position:'relative', zIndex:5 }}>
        <PermRow
          icon={<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="7" width="18" height="13" rx="3"/><circle cx="12" cy="13" r="4"/><path d="M9 7l1.5-3h3L15 7"/></svg>}
          color={DH.PINK} deep={DH.PINK_DEEP}
          title="Camera" sub="See yourself in the magic mirror"
          status="Required"
        />
        <PermRow
          icon={<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="18" height="18" rx="3"/><path d="M3 16l5-5 4 4 3-3 6 6"/><circle cx="9" cy="9" r="1.5"/></svg>}
          color={DH.LAV} deep="#7A53C9"
          title="Photos" sub="Save your favorite looks to camera roll"
          status="Optional"
        />
        <PermRow
          icon={<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={DH.INK} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M18 8a6 6 0 10-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M10 21h4"/></svg>}
          color={DH.BUTTER} deep="#C99B1F" iconColor={DH.INK}
          title="Notifications" sub="Weekly look drops & friend requests"
          status="Optional"
        />
      </div>

      {/* CTAs */}
      <div style={{ position:'absolute', bottom:60, left:18, right:18, display:'flex', flexDirection:'column', gap:10, zIndex:5 }}>
        <DHButton kind="primary" size="xl" style={{ width: '100%' }}>Allow all & continue</DHButton>
        <button style={{
          height:42, background:'transparent', border:'none', cursor:'pointer',
          fontFamily:DH.font, fontWeight:700, fontSize:12, color:'rgba(58,14,37,0.55)', letterSpacing:'0.06em',
        }}>Set up later in Settings</button>
      </div>

      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}

function PermRow({ icon, color, deep, iconColor='#fff', title, sub, status }) {
  return (
    <DHCard color="#fff" deep={DH.PINK_LIGHT} br={20} pad={12} style={{ display:'flex', alignItems:'center', gap:12 }}>
      <div style={{
        width:48, height:48, borderRadius:16, background:color, display:'flex', alignItems:'center', justifyContent:'center',
        boxShadow:`0 3px 0 ${deep}`, color: iconColor,
      }}>{icon}</div>
      <div style={{ flex:1 }}>
        <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:15, color:DH.INK }}>{title}</div>
        <div style={{ fontFamily:DH.font, fontWeight:500, fontSize:11.5, color:'rgba(58,14,37,0.55)', marginTop:1 }}>{sub}</div>
      </div>
      <div style={{
        padding:'5px 10px', borderRadius:99, background: status==='Required'?DH.PINK_PAPER:'rgba(58,14,37,0.06)',
        fontFamily:DH.font, fontWeight:700, fontSize:10, letterSpacing:'0.08em', textTransform:'uppercase',
        color: status==='Required'?DH.PINK_DEEP:'rgba(58,14,37,0.55)',
      }}>{status}</div>
    </DHCard>
  );
}
window.DHPermissions = DHPermissions;
