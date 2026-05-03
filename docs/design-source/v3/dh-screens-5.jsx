// GRWM Studio — Feed (community), Look Detail, Tutorial

// =====================================================================
// FEED — Pinterest-style mosaic of friends' looks, ranked by hearts
function DHFeed() {
  const cards = [
    { h:240, name:'Maya',    handle:'@mayaglossy',  hearts:124, mins:'2m',  skin:'#FFD9C0', lip:DH.PINK,    eye:DH.LAV,     blush:DH.PINK_LIGHT, color:DH.PINK_LIGHT, deep:DH.PINK_DEEP, comment:'cherry crush vibes ♡' },
    { h:200, name:'Zee',     handle:'@zeezee',      hearts:88,  mins:'12m', skin:'#F5C8A6', lip:'#7AB8FF',  eye:'#7AE8E0',  blush:'#A8D8FF',     color:'#C8EAFF',     deep:'#3D7FBF',    tag:'WATER',     comment:'mermaid era 🧜‍♀️' },
    { h:260, name:'Kai',     handle:'@kaiglow',     hearts:312, mins:'1h',  skin:'#FFD9C0', lip:'#9C2BFF',  eye:'#FF52E8',  blush:'#FFB8DC',     color:'#E8C8FF',     deep:'#5A1099',    tag:'BOLD',      hot:true, comment:'disco brat strikes again' },
    { h:220, name:'Iris',    handle:'@iristhebabe', hearts:67,  mins:'3h',  skin:'#FFE0CC', lip:'#E8A0A8',  eye:'#F5D4C0',  blush:'#FFB8B8',     color:'#FFE4D8',     deep:'#C98090',    tag:'SOFT',      comment:'natural day ☁️' },
  ];
  return (
    <GPhone bg={DH.CREAM} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`linear-gradient(180deg, ${DH.PINK_PAPER}, ${DH.CREAM} 30%)` }}/>
      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      {/* Header */}
      <div style={{ padding:'4px 18px 0', display:'flex', alignItems:'center', justifyContent:'space-between', position:'relative', zIndex:5 }}>
        <div>
          <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:11, color:'rgba(58,14,37,0.5)', letterSpacing:'0.16em' }}>YOUR SQUAD</div>
          <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:30, color:DH.PINK_DEEP, letterSpacing:'-0.02em', lineHeight:1, marginTop:2 }}>The Feed ♡</div>
        </div>
        <div style={{ display:'flex', gap:6 }}>
          <button style={{ width:42, height:42, borderRadius:21, background:'#fff', border:'none', cursor:'pointer', boxShadow: DH.shadow(DH.PINK), display:'flex', alignItems:'center', justifyContent:'center' }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="2.6" strokeLinecap="round"><path d="M18 8a6 6 0 10-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M10 21h4"/></svg>
            <span style={{ position:'absolute', top:-2, right:-2, width:14, height:14, borderRadius:7, background:DH.BUTTER, boxShadow:`0 1px 0 #C99B1F`, color:DH.INK, fontFamily:DH.font, fontWeight:800, fontSize:9, display:'flex', alignItems:'center', justifyContent:'center' }}>3</span>
          </button>
        </div>
      </div>

      {/* Stories rail */}
      <div style={{ padding:'14px 0 0', position:'relative', zIndex:5 }}>
        <div style={{ display:'flex', gap:10, overflowX:'auto', padding:'0 18px 6px' }}>
          {/* Your story (add) */}
          <div style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:4, minWidth:64 }}>
            <div style={{ width:64, height:64, borderRadius:32, background:'#fff', border:`3px dashed ${DH.PINK}`, display:'flex', alignItems:'center', justifyContent:'center' }}>
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="3" strokeLinecap="round"><path d="M12 5v14M5 12h14"/></svg>
            </div>
            <span style={{ fontFamily:DH.font, fontWeight:700, fontSize:10, color:DH.INK }}>You</span>
          </div>
          {[
            { c:DH.PINK_LIGHT, deep:DH.PINK_DEEP, n:'Maya',  s:'#FFD9C0', l:DH.PINK },
            { c:'#C8EAFF',     deep:'#3D7FBF',    n:'Zee',   s:'#F5C8A6', l:'#7AB8FF' },
            { c:'#E8C8FF',     deep:'#5A1099',    n:'Kai',   s:'#FFD9C0', l:'#9C2BFF' },
            { c:DH.BUTTER,     deep:'#C99B1F',    n:'Iris',  s:'#FFE0CC', l:'#E8A0A8' },
            { c:DH.MINT,       deep:'#5DBD8E',    n:'Sam',   s:'#F5C8A6', l:'#7AE8E0' },
          ].map(s => (
            <div key={s.n} style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:4, minWidth:64 }}>
              <div style={{
                width:64, height:64, borderRadius:32, padding:3, background:`conic-gradient(from 0deg, ${DH.PINK} 0%, ${DH.LAV} 33%, ${DH.BUTTER} 66%, ${DH.PINK} 100%)`,
                boxShadow: DH.shadow(s.deep),
              }}>
                <div style={{ width:'100%', height:'100%', borderRadius:'50%', background:s.c, border:`2px solid #fff`, overflow:'hidden', position:'relative' }}>
                  <div style={{ position:'absolute', bottom:-12, left:'50%', transform:'translateX(-50%) scale(0.42)', transformOrigin:'bottom center' }}>
                    <FaceMock skin={s.s} lipColor={s.l} blushColor={s.l} smile size={1.0}/>
                  </div>
                </div>
              </div>
              <span style={{ fontFamily:DH.font, fontWeight:700, fontSize:10, color:DH.INK }}>{s.n}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Mosaic (2-col masonry-ish) */}
      <div style={{ padding:'14px 18px 130px', display:'grid', gridTemplateColumns:'1fr 1fr', gap:10, position:'relative', zIndex:5 }}>
        <div style={{ display:'flex', flexDirection:'column', gap:10 }}>
          {[cards[0], cards[2]].map(c => <FeedCard key={c.name} c={c}/>)}
        </div>
        <div style={{ display:'flex', flexDirection:'column', gap:10, paddingTop:24 }}>
          {[cards[1], cards[3]].map(c => <FeedCard key={c.name} c={c}/>)}
        </div>
      </div>

      <DHTabBar active="feed"/>
      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}

function FeedCard({ c }) {
  return (
    <DHCard color={c.color} deep={c.deep} br={20} pad={0} style={{ position:'relative', overflow:'hidden', height:c.h }}>
      {/* face */}
      <div style={{ position:'absolute', bottom:-16, left:'50%', transform:'translateX(-50%) scale(0.7)', transformOrigin:'bottom center' }}>
        <FaceMock skin={c.skin} lipColor={c.lip} eyeShadow={c.eye} blushColor={c.blush} smile size={1.0}/>
      </div>
      {/* hot badge */}
      {c.hot && (
        <div style={{
          position:'absolute', top:8, left:8, padding:'4px 8px', borderRadius:99,
          background:DH.BUTTER, boxShadow:`0 2px 0 #C99B1F`,
          fontFamily:DH.font, fontWeight:800, fontSize:9, letterSpacing:'0.1em', color:DH.INK,
        }}>🔥 HOT</div>
      )}
      {/* footer overlay */}
      <div style={{
        position:'absolute', bottom:0, left:0, right:0, padding:'24px 10px 8px',
        background:`linear-gradient(180deg, transparent, ${c.deep}dd 60%)`,
      }}>
        <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:11, color:'#fff', opacity:0.85 }}>{c.handle} · {c.mins}</div>
        <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:12, color:'#fff', marginTop:2, lineHeight:1.2 }}>{c.comment}</div>
        <div style={{ marginTop:6, display:'flex', alignItems:'center', gap:6 }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="#fff"><path d="M12 21S2 14 2 8a5 5 0 019-3 5 5 0 019 3c0 6-8 13-8 13z"/></svg>
          <span style={{ fontFamily:DH.font, fontWeight:800, fontSize:11, color:'#fff' }}>{c.hearts}</span>
        </div>
      </div>
    </DHCard>
  );
}
window.DHFeed = DHFeed;

// =====================================================================
// LOOK DETAIL — when you tap a saved look
function DHLookDetail() {
  return (
    <GPhone bg={DH.PINK_LIGHT} ringColor="rgba(212,18,123,0.3)">
      <div style={{ position:'absolute', inset:0, background:`linear-gradient(180deg, ${DH.PINK_LIGHT} 0%, ${DH.PINK} 50%, ${DH.PINK_DEEP} 100%)` }}/>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color="#fff"/></div>

      {/* Top bar */}
      <div style={{ padding:'4px 18px 0', display:'flex', alignItems:'center', justifyContent:'space-between', position:'relative', zIndex:5 }}>
        <button style={{
          width:42, height:42, borderRadius:21, background:'rgba(255,255,255,0.3)', border:'none', cursor:'pointer',
          backdropFilter:'blur(8px)', display:'flex', alignItems:'center', justifyContent:'center',
        }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="3" strokeLinecap="round"><path d="M15 18l-6-6 6-6"/></svg>
        </button>
        <button style={{
          width:42, height:42, borderRadius:21, background:'rgba(255,255,255,0.3)', border:'none', cursor:'pointer',
          backdropFilter:'blur(8px)', display:'flex', alignItems:'center', justifyContent:'center',
        }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.6" strokeLinecap="round"><circle cx="12" cy="6" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="12" cy="18" r="1.5"/></svg>
        </button>
      </div>

      {/* Big preview */}
      <div style={{ padding:'14px 18px 0', position:'relative', zIndex:5 }}>
        <DHCard color="#fff" deep={DH.PINK_DEEP} br={28} pad={10} style={{ position:'relative' }}>
          <div style={{
            height:340, borderRadius:20, position:'relative', overflow:'hidden',
            background:`linear-gradient(180deg, ${DH.PINK_LIGHT}, ${DH.PINK})`,
          }}>
            <div style={{ position:'absolute', bottom:-10, left:'50%', transform:'translateX(-50%) scale(1.2)' }}>
              <FaceMock skin="#FFD9C0" lipColor={DH.PINK_DEEP} lipShine="#fff" blushColor={DH.PINK} blushOpacity={0.55} eyeShadow={DH.LAV} eyeShadowOpacity={0.6} smile size={1.0}/>
            </div>
            <div style={{ position:'absolute', top:14, left:14 }}><StickerSparkle size={20} fill="#fff"/></div>
            <div style={{ position:'absolute', top:50, right:18 }}><StickerSparkle size={14} fill={DH.BUTTER}/></div>
          </div>
          {/* hearts pill floating */}
          <div style={{
            position:'absolute', top:24, right:24, padding:'6px 10px', borderRadius:99,
            background:'rgba(255,255,255,0.85)', backdropFilter:'blur(6px)',
            boxShadow:`0 3px 0 ${DH.PINK_LIGHT}`,
            fontFamily:DH.font, fontWeight:800, fontSize:12, color:DH.PINK_DEEP, display:'flex', alignItems:'center', gap:5,
          }}>
            <svg width="12" height="12" viewBox="0 0 24 24" fill={DH.PINK_DEEP}><path d="M12 21S2 14 2 8a5 5 0 019-3 5 5 0 019 3c0 6-8 13-8 13z"/></svg>
            148
          </div>
        </DHCard>
      </div>

      {/* Detail card */}
      <div style={{ padding:'14px 18px 0', position:'relative', zIndex:5 }}>
        <DHCard color="#fff" deep={DH.PINK} br={24} pad={16}>
          <div style={{ display:'flex', alignItems:'baseline', justifyContent:'space-between', gap:8 }}>
            <div>
              <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:10, color:'rgba(58,14,37,0.55)', letterSpacing:'0.16em' }}>LOOK № 007</div>
              <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:24, color:DH.PINK_DEEP, lineHeight:1, marginTop:2 }}>Bubblegum Pop ✨</div>
            </div>
            <button style={{
              width:38, height:38, borderRadius:19, background:DH.PINK, border:'none', cursor:'pointer',
              boxShadow: DH.shadow(DH.PINK_DEEP), display:'flex', alignItems:'center', justifyContent:'center',
            }}>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="#fff"><path d="M12 21S2 14 2 8a5 5 0 019-3 5 5 0 019 3c0 6-8 13-8 13z"/></svg>
            </button>
          </div>

          {/* Tags */}
          <div style={{ marginTop:10, display:'flex', flexWrap:'wrap', gap:6 }}>
            <DHChip sel>♡ Cute</DHChip>
            <DHChip sel>✦ Glossy</DHChip>
            <DHChip sel>Daytime</DHChip>
          </div>

          {/* Recipe rows */}
          <div style={{ marginTop:14, fontFamily:DH.font, fontWeight:700, fontSize:11, color:'rgba(58,14,37,0.55)', letterSpacing:'0.16em' }}>THE RECIPE</div>
          <div style={{ marginTop:8, display:'flex', flexDirection:'column', gap:6 }}>
            <RecipeRow color={DH.PINK} name="Lips" shade="Showtime № 007"/>
            <RecipeRow color={DH.LAV} name="Eyes" shade="Lavender Daze"/>
            <RecipeRow color={DH.PINK_LIGHT} name="Cheek" shade="Sweet Cheeks"/>
          </div>
        </DHCard>
      </div>

      {/* Action buttons */}
      <div style={{ position:'absolute', bottom:46, left:18, right:18, display:'flex', gap:10, zIndex:5 }}>
        <DHButton kind="white" size="lg" style={{ flex:1 }}
          icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="2.6" strokeLinecap="round"><path d="M4 12v8a2 2 0 002 2h12a2 2 0 002-2v-8M16 6l-4-4-4 4M12 2v13"/></svg>}>
          Share
        </DHButton>
        <DHButton kind="primary" size="lg" style={{ flex:1.4 }}
          icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.6" strokeLinecap="round"><path d="M5 3v18l7-5 7 5V3z"/></svg>}>
          Try this look
        </DHButton>
      </div>

      <GHomeIndicator color="rgba(255,255,255,0.5)"/>
    </GPhone>
  );
}

function RecipeRow({ color, name, shade }) {
  return (
    <div style={{
      display:'flex', alignItems:'center', gap:10, padding:'8px 10px', borderRadius:14,
      background:DH.PINK_PAPER,
    }}>
      <div style={{
        width:28, height:28, borderRadius:14, background:color,
        boxShadow:`inset 0 -2px 0 rgba(0,0,0,0.15), inset 0 2px 0 rgba(255,255,255,0.4), 0 2px 0 rgba(212,18,123,0.2)`,
        border:`2px solid #fff`,
      }}/>
      <div style={{ flex:1 }}>
        <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:12, color:DH.INK, lineHeight:1 }}>{name}</div>
        <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:11, color:'rgba(58,14,37,0.55)', marginTop:2 }}>{shade}</div>
      </div>
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="2.6" strokeLinecap="round"><path d="M9 6l6 6-6 6"/></svg>
    </div>
  );
}
window.DHLookDetail = DHLookDetail;

// =====================================================================
// TUTORIAL — step-by-step guided look
function DHTutorial() {
  return (
    <GPhone bg={DH.CREAM} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`linear-gradient(180deg, ${DH.PINK_PAPER}, ${DH.CREAM} 40%)` }}/>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      {/* Top bar with stepper */}
      <div style={{ padding:'4px 18px 0', display:'flex', alignItems:'center', justifyContent:'space-between', position:'relative', zIndex:5 }}>
        <button style={{
          width:42, height:42, borderRadius:21, background:'#fff', border:'none', cursor:'pointer',
          boxShadow: DH.shadow(DH.PINK), display:'flex', alignItems:'center', justifyContent:'center',
        }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={DH.PINK_DEEP} strokeWidth="3" strokeLinecap="round"><path d="M6 6L18 18M18 6L6 18"/></svg>
        </button>
        <div style={{ fontFamily:DH.font, fontWeight:800, fontSize:11, color:DH.PINK_DEEP, letterSpacing:'0.12em' }}>STEP 2 OF 4</div>
        <div style={{ width:42 }}/>
      </div>

      {/* Step progress dots */}
      <div style={{ padding:'10px 36px 0', display:'flex', alignItems:'center', gap:6, position:'relative', zIndex:5 }}>
        {[1,2,3,4].map(n => (
          <React.Fragment key={n}>
            <div style={{
              width:28, height:28, borderRadius:14,
              background: n <= 2 ? DH.PINK : '#fff',
              color: n <= 2 ? '#fff' : 'rgba(212,18,123,0.4)',
              boxShadow: n <= 2 ? DH.shadow(DH.PINK_DEEP) : `0 2px 0 ${DH.PINK_LIGHT}`,
              display:'flex', alignItems:'center', justifyContent:'center',
              fontFamily:DH.font, fontWeight:800, fontSize:12,
            }}>{n}</div>
            {n < 4 && <div style={{ flex:1, height:4, borderRadius:2, background: n < 2 ? DH.PINK : 'rgba(212,18,123,0.15)' }}/>}
          </React.Fragment>
        ))}
      </div>

      {/* Step illustration */}
      <div style={{ padding:'18px 18px 0', position:'relative', zIndex:5 }}>
        <DHCard color={DH.PINK_LIGHT} deep={DH.PINK} br={28} pad={0} style={{ position:'relative', overflow:'hidden', height:280 }}>
          {/* face mock */}
          <div style={{ position:'absolute', bottom:-30, left:'50%', transform:'translateX(-50%) scale(0.95)' }}>
            <FaceMock skin="#FFD4B8" lipColor="#E8A0A8" eyeShadow={DH.LAV} eyeShadowOpacity={0.7} blushColor={DH.PINK_LIGHT} smile size={1.0}/>
          </div>
          {/* highlight ring around eyes */}
          <div style={{
            position:'absolute', top:64, left:'50%', transform:'translateX(-50%)',
            width:200, height:80, borderRadius:'50%', border:`4px dashed #fff`, opacity:0.85,
          }}/>
          {/* finger pointer */}
          <div style={{ position:'absolute', top:54, right:32, fontSize:42, transform:'rotate(-12deg)' }}>👆</div>
          {/* sparkles */}
          <div style={{ position:'absolute', top:24, left:24 }}><StickerSparkle size={22} fill="#fff"/></div>
          <div style={{ position:'absolute', top:50, right:130 }}><StickerSparkle size={14} fill={DH.BUTTER}/></div>
        </DHCard>
      </div>

      {/* Title + description */}
      <div style={{ padding:'18px 24px 0', position:'relative', zIndex:5 }}>
        <div style={{ fontFamily:DH.font, fontWeight:600, fontSize:11, color:DH.PINK_DEEP, opacity:0.6, letterSpacing:'0.16em' }}>LIVE LOOK · DOLL EYES</div>
        <div style={{ marginTop:4, fontFamily:DH.font, fontWeight:700, fontSize:28, color:DH.INK, letterSpacing:'-0.02em', lineHeight:1.05 }}>Now sweep on the lavender shadow</div>
        <div style={{ marginTop:8, fontFamily:DH.font, fontWeight:500, fontSize:13.5, color:'rgba(58,14,37,0.7)', lineHeight:1.45 }}>
          Use light, fluttery taps along the lid. Let it bloom out toward the corners. The mirror will fade it in for you ✨
        </div>
      </div>

      {/* Tip pill */}
      <div style={{ padding:'14px 18px 0', position:'relative', zIndex:5 }}>
        <DHCard color={DH.BUTTER} deep="#C99B1F" br={18} pad={12} style={{ display:'flex', gap:10, alignItems:'center' }}>
          <div style={{ fontSize:24 }}>💡</div>
          <div style={{ flex:1, fontFamily:DH.font, fontWeight:600, fontSize:12, color:DH.INK, lineHeight:1.35 }}>
            <b style={{ fontWeight:800 }}>Tip:</b> Tap and hold to soften. Double-tap to amp up the shimmer.
          </div>
        </DHCard>
      </div>

      {/* CTAs */}
      <div style={{ position:'absolute', bottom:46, left:18, right:18, display:'flex', gap:10, zIndex:5 }}>
        <DHButton kind="ghost" size="xl" style={{ flex:1 }}>Skip</DHButton>
        <DHButton kind="primary" size="xl" style={{ flex:1.6 }}
          iconRight={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.8" strokeLinecap="round"><path d="M5 12h14M13 5l7 7-7 7"/></svg>}>
          Got it!
        </DHButton>
      </div>

      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}
window.DHTutorial = DHTutorial;
