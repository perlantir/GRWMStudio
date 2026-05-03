// GRWM Studio — Error states & a couple "Reminder" pieces
// One generic <DHError> component drives 9 variants.
// Each error keeps the playful plastic-toy tone — no scary red flags.

function DHError({ variant }) {
  const presets = {
    'cam-denied': {
      tone:'pink',  emoji:'📷',
      sticker:<StickerHeart size={26} fill={DH.PINK_DEEP} stroke="#fff" sw={2.5}/>,
      title:"The mirror can't see you 💕",
      sub:"Camera access was turned off. Tap below to switch it back on in Settings.",
      cta:'Open Settings', alt:"I'll do it later",
    },
    'mic-denied': {
      tone:'lav',   emoji:'🎙️',
      sticker:<StickerSparkle size={24} fill={DH.LAV}/>,
      title:"No microphone, no voiceover",
      sub:"Recording works without sound, but giggles are nicer with audio.",
      cta:'Turn on Microphone', alt:'Record without sound',
    },
    'photo-denied': {
      tone:'butter', emoji:'🖼️',
      sticker:<StickerSparkle size={24} fill={DH.BUTTER}/>,
      title:"Can't reach Photos",
      sub:"Photos access is off, so we can't save your video to the camera roll. Looks still save inside GRWM.",
      cta:'Allow Photos', alt:'Keep inside GRWM',
    },
    'license': {
      tone:'pink',  emoji:'🔒',
      sticker:<StickerStar size={26} fill={DH.BUTTER}/>,
      title:"This shade is Pro",
      sub:"Disco Brat is part of Studio Pro. Want a peek at everything?",
      cta:'See Pro stuff', alt:'Maybe later',
    },
    'effect-fail': {
      tone:'mint',  emoji:'✨',
      sticker:<StickerSparkle size={24} fill={DH.MINT}/>,
      title:"That sparkle didn't load",
      sub:"The effect couldn't download. Check your wifi and try again — it'll only take a sec.",
      cta:'Try again', alt:'Pick a different look',
    },
    'rec-fail': {
      tone:'pink',  emoji:'🎬',
      sticker:<StickerHeart size={26} fill={DH.PINK} stroke="#fff" sw={2}/>,
      title:"Recording didn't save",
      sub:"Something hiccuped while saving. Don't worry — you can record it again right now.",
      cta:'Record again', alt:'Discard',
    },
    'save-fail': {
      tone:'butter', emoji:'💼',
      sticker:<StickerHeart size={24} fill={DH.PINK_DEEP}/>,
      title:"Couldn't add to Locker",
      sub:"There was a problem saving this look. Your last 3 looks are still safe inside the app.",
      cta:'Try saving again', alt:'Throw away',
    },
    'no-face': {
      tone:'lav',   emoji:'👀',
      sticker:<StickerSparkle size={24} fill={DH.PINK}/>,
      title:"I can't see your face!",
      sub:"Move into the light, or come a little closer to the camera so the makeup can land.",
      cta:'Got it, try again', alt:'Use a sample face',
    },
    'low-storage': {
      tone:'pink',  emoji:'📦',
      sticker:<StickerStar size={24} fill={DH.BUTTER}/>,
      title:"Almost out of space",
      sub:"Your phone is nearly full. Free up some room or your next save might not stick.",
      cta:'Show me how', alt:'Save anyway',
    },
  };
  const p = presets[variant] || presets['cam-denied'];

  // Tone palette
  const tones = {
    pink:   { hero:DH.PINK,        deep:DH.PINK_DEEP,   bg:DH.PINK_PAPER,  card:'#fff' },
    lav:    { hero:DH.LAV,         deep:'#5A1099',      bg:'#F1E8FF',      card:'#fff' },
    butter: { hero:DH.BUTTER,      deep:'#C99B1F',      bg:'#FFF6E0',      card:'#fff' },
    mint:   { hero:DH.MINT,        deep:'#5DBD8E',      bg:'#E5FFF4',      card:'#fff' },
  };
  const t = tones[p.tone];

  return (
    <GPhone bg={t.bg} ringColor="rgba(212,18,123,0.25)">
      <div style={{ position:'absolute', inset:0, background:`linear-gradient(180deg, ${t.bg}, ${DH.CREAM} 50%)` }}/>

      <GDynamicIsland/>
      <div style={{ position:'relative', zIndex:10 }}><GStatusBar color={DH.PINK_DEEP}/></div>

      {/* Top close */}
      <div style={{ padding:'4px 18px 0', display:'flex', justifyContent:'flex-end', position:'relative', zIndex:5 }}>
        <button style={{ width:42, height:42, borderRadius:21, background:'#fff', border:'none', boxShadow:DH.shadow(t.hero), display:'flex', alignItems:'center', justifyContent:'center' }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={t.deep} strokeWidth="3" strokeLinecap="round"><path d="M6 6L18 18M18 6L6 18"/></svg>
        </button>
      </div>

      {/* Hero icon */}
      <div style={{ padding:'24px 18px 0', display:'flex', justifyContent:'center', position:'relative', zIndex:5 }}>
        <div style={{
          width:160, height:160, borderRadius:80,
          background:`radial-gradient(circle at 30% 30%, #fff, ${t.hero})`,
          border:`6px solid #fff`, boxShadow:`0 7px 0 ${t.deep}, 0 14px 24px rgba(0,0,0,0.15)`,
          display:'flex', alignItems:'center', justifyContent:'center', position:'relative',
        }}>
          <div style={{ fontSize:80 }}>{p.emoji}</div>
          <div style={{ position:'absolute', top:-4, right:-4, transform:'rotate(15deg)' }}>{p.sticker}</div>
        </div>
      </div>

      {/* Copy */}
      <div style={{ padding:'24px 28px 0', textAlign:'center', position:'relative', zIndex:5 }}>
        <div style={{ fontFamily:DH.font, fontWeight:700, fontSize:24, color:DH.INK, letterSpacing:'-0.01em', lineHeight:1.1 }}>
          {p.title}
        </div>
        <div style={{ marginTop:12, fontFamily:DH.font, fontWeight:500, fontSize:14, color:'rgba(58,14,37,0.7)', lineHeight:1.5 }}>
          {p.sub}
        </div>
      </div>

      {/* Variant chip */}
      <div style={{ position:'absolute', top:130, left:18, padding:'5px 10px', borderRadius:99, background:'rgba(58,14,37,0.08)', fontFamily:DH.font, fontWeight:700, fontSize:9.5, color:'rgba(58,14,37,0.55)', letterSpacing:'0.12em' }}>
        ERROR · {variant.toUpperCase()}
      </div>

      {/* CTAs */}
      <div style={{ position:'absolute', bottom:46, left:18, right:18, display:'flex', flexDirection:'column', gap:8, zIndex:5 }}>
        <DHButton kind="primary" size="xl" style={{ width:'100%', background:t.hero, boxShadow:`0 5px 0 ${t.deep}, inset 0 2px 0 rgba(255,255,255,0.4)` }}>
          {p.cta}
        </DHButton>
        <DHButton kind="ghost" size="md" style={{ width:'100%' }}>{p.alt}</DHButton>
      </div>

      <GHomeIndicator color={DH.PINK_DEEP}/>
    </GPhone>
  );
}
window.DHError = DHError;

// (StickerStar comes from grwm-shared.jsx)
