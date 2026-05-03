// GRWM Studio — Looks Library (browse + filter saved looks)

function DHLooks() {
  const looks = [
    { id:1, name:'Bubblegum Pop',   tag:'CUTE',     skin:'#FFD9C0', lip:DH.PINK,        eye:DH.LAV,         blush:DH.PINK_LIGHT, hearts:3, deep:DH.PINK_DEEP, color:DH.PINK_LIGHT, hot:true },
    { id:2, name:'Sunset Crush',    tag:'WARM',     skin:'#F5C8A6', lip:'#E84A5F',      eye:'#FFB070',      blush:'#FF8A8A',     hearts:1, deep:'#C9442A', color:'#FFD3B8' },
    { id:3, name:'Mermaid Tears',   tag:'AQUATIC',  skin:'#FFD9C0', lip:'#7AB8FF',      eye:'#7AE8E0',      blush:'#A8D8FF',     hearts:5, deep:'#3D7FBF', color:'#C8EAFF', hot:true },
    { id:4, name:'Cherry Glaze',    tag:'GLOSSY',   skin:'#F5C8A6', lip:'#C8264A',      eye:'#E4B0C8',      blush:'#E8728C',     hearts:2, deep:'#8C1E33', color:'#F5C0CC' },
    { id:5, name:'Soft Doll',       tag:'NATURAL',  skin:'#FFE0CC', lip:'#E8A0A8',      eye:'#F5D4C0',      blush:'#FFB8B8',     hearts:0, deep:'#C98090', color:'#FFE4D8' },
    { id:6, name:'Disco Brat',      tag:'BOLD',     skin:'#FFD9C0', lip:'#9C2BFF',      eye:'#FF52E8',      blush:'#FFB8DC',     hearts:7, deep:'#5A1099', color:'#E8C8FF', hot:true },
  ];

  return (
    <GPhone bg={DH.CREAM} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`linear-gradient(180deg, ${DH.PINK_PAPER}, ${DH.CREAM} 30%)` }}/>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      {/* Header */}
      <div style={{ padding:'4px 18px 0', display:'flex', alignItems:'center', justifyContent:'space-between', position:'relative', zIndex:5 }}>
        <div>
          <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:11, color:'rgba(58,14,37,0.5)', letterSpacing:'0.16em' }}>YOUR LOOKS</div>
          <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:30, color:DH.PINK_DEEP, letterSpacing:'-0.02em', lineHeight:1, marginTop:2 }}>Looks Locker</div>
        </div>
        <button style={{
          width:42, height:42, borderRadius:21, background:'#fff', border:'none', cursor:'pointer',
          boxShadow: DH.shadow(DH.PINK), display:'flex', alignItems:'center', justifyContent:'center',
        }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="2.6" strokeLinecap="round"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.5-4.5"/></svg>
        </button>
      </div>

      {/* Stats strip */}
      <div style={{ padding:'14px 18px 0', display:'flex', gap:8, position:'relative', zIndex:5 }}>
        <DHCard color="#fff" deep={DH.PINK_LIGHT} br={16} pad={10} style={{ flex:1 }}>
          <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:22, color:DH.PINK_DEEP, lineHeight:1 }}>24</div>
          <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:10, color:'rgba(58,14,37,0.55)', letterSpacing:'0.1em', marginTop:2 }}>SAVED</div>
        </DHCard>
        <DHCard color={DH.BUTTER} deep="#C99B1F" br={16} pad={10} style={{ flex:1 }}>
          <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:22, color:DH.INK, lineHeight:1 }}>148</div>
          <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:10, color:'rgba(58,14,37,0.7)', letterSpacing:'0.1em', marginTop:2 }}>HEARTS</div>
        </DHCard>
        <DHCard color={DH.LAV} deep="#7A53C9" br={16} pad={10} style={{ flex:1 }}>
          <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:22, color:'#fff', lineHeight:1 }}>7</div>
          <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:10, color:'rgba(255,255,255,0.85)', letterSpacing:'0.1em', marginTop:2 }}>FRIENDS</div>
        </DHCard>
      </div>

      {/* Filter chips */}
      <div style={{ padding:'14px 18px 0', display:'flex', gap:6, overflowX:'auto', position:'relative', zIndex:5 }}>
        <DHChip sel>✦ All</DHChip>
        <DHChip>♡ Faves</DHChip>
        <DHChip>Cute</DHChip>
        <DHChip>Bold</DHChip>
        <DHChip>Soft</DHChip>
        <DHChip>Aquatic</DHChip>
      </div>

      {/* Grid */}
      <div style={{ padding:'14px 18px 130px', display:'grid', gridTemplateColumns:'1fr 1fr', gap:12, position:'relative', zIndex:5 }}>
        {looks.map(l => <LookTile key={l.id} look={l}/>)}
      </div>

      <DHTabBar active="looks"/>
      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}

function LookTile({ look }) {
  return (
    <DHCard color={look.color} deep={look.deep} br={22} pad={0} style={{ position:'relative', overflow:'hidden', height:200 }}>
      {/* face mock peeking from bottom */}
      <div style={{ position:'absolute', bottom:-30, left:'50%', transform:'translateX(-50%) scale(0.7)' }}>
        <FaceMock skin={look.skin} lipColor={look.lip} eyeShadow={look.eye} blushColor={look.blush} smile size={1.0}/>
      </div>
      {/* hot badge */}
      {look.hot && (
        <div style={{
          position:'absolute', top:8, left:8, padding:'4px 8px', borderRadius:99,
          background:DH.BUTTER, boxShadow:`0 2px 0 #C99B1F`,
          fontFamily:DH.font, fontWeight:800, fontSize:9, letterSpacing:'0.1em', color:DH.INK,
        }}>🔥 HOT</div>
      )}
      {/* hearts pill */}
      <div style={{
        position:'absolute', top:8, right:8, padding:'4px 8px', borderRadius:99,
        background:'rgba(255,255,255,0.7)', backdropFilter:'blur(4px)',
        fontFamily:DH.font, fontWeight:700, fontSize:10, color:DH.PINK_DEEP,
        display:'flex', alignItems:'center', gap:3,
      }}>
        <svg width="10" height="10" viewBox="0 0 24 24" fill={DH.PINK_DEEP}><path d="M12 21S2 14 2 8a5 5 0 019-3 5 5 0 019 3c0 6-8 13-8 13z"/></svg>
        {look.hearts}
      </div>
      {/* name footer */}
      <div style={{
        position:'absolute', bottom:0, left:0, right:0, padding:'18px 10px 8px',
        background:`linear-gradient(180deg, transparent, ${look.deep}cc 60%)`,
      }}>
        <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:13, color:'#fff', letterSpacing:'-0.01em', lineHeight:1 }}>{look.name}</div>
        <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:9, color:'rgba(255,255,255,0.8)', letterSpacing:'0.12em', marginTop:3 }}>{look.tag}</div>
      </div>
    </DHCard>
  );
}
window.DHLooks = DHLooks;
