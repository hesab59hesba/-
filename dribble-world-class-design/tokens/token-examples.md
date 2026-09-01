# Token System Examples by Category

## Category: Software / SaaS Landing Page

### Subject: AI-powered analytics platform "Nexus"
- **Audience**: Data teams, product managers, CTOs
- **Job**: Convince visitors to start a free trial
- **Mode**: Expressive

```css
/* Token System */
:root {
  --bg: #f4f3f0;          /* Warm gray-white */
  --surface: #ffffff;
  --text: #0f172a;        /* Deep navy, not pure black */
  --muted: #64748b;
  --light: #e2e8f0;
  
  --primary: #0ea5e9;     /* Sky blue — trust, data, clarity */
  --secondary: #8b5cf6;   /* Violet — AI, intelligence */
  --accent: #06b6d4;      /* Cyan — precision, tech */
  --success: #10b981;     /* Green — positive metrics */
  --warning: #f59e0b;     /* Amber — attention needed */
  
  --gradient-main: linear-gradient(135deg, #0ea5e9, #8b5cf6);
  --gradient-accent: linear-gradient(135deg, #0ea5e9, #06b6d4, #8b5cf6);
}

.type-display: 'Inter Tight', system-ui;    weight: 900, tracking: -0.03em
.type-body: 'Inter', system-ui;             weight: 400-500
.type-mono: 'JetBrains Mono', monospace;    weight: 500
```

**Signature**: Interactive chart visualization in hero that updates with real-looking data on load (bar charts animate up, line chart draws itself).

**Layout**: Bento grid for features section. Split-screen hero. Centered CTA at bottom.

---

### Subject: Developer API platform "Forge"
- **Audience**: Engineers, technical founders
- **Job**: Drive sign-ups and documentation exploration
- **Mode**: Expressive

```css
:root {
  --bg: #0c0c14;         /* Very dark blue-black */
  --surface: rgba(255,255,255,0.03);
  --text: #e2e8f0;       /* Cool white */
  --muted: rgba(255,255,255,0.4);
  --light: rgba(255,255,255,0.08);
  
  --primary: #6366f1;    /* Indigo — developer tools standard */
  --accent: #a78bfa;     /* Light violet — secondary emphasis */
  --terminal-green: #22c55e;
  
  --gradient-main: linear-gradient(135deg, #6366f1, #a78bfa);
}
```

**Signature**: Code snippet hero — actual API call in syntax-highlighted terminal, with cursor blinking and response streaming in.

**Layout**: Minimal nav centered. Full-width code block as hero visual. Documentation preview below.

---

### Subject: Project management tool "Flux"
- **Audience**: Creative teams, agencies
- **Job**: Book a demo
- **Mode**: Convention-Plus (it's a product page inside a product)

```css
:root {
  --bg: #fafafa;
  --surface: #ffffff;
  --text: #171717;
  --muted: #737373;
  --light: #e5e5e5;
  
  --primary: #f97316;    /* Orange — energy, action, creativity */
  --secondary: #ec4899;  /* Pink — creative, playful */
  
  --gradient-main: linear-gradient(135deg, #f97316, #ec4899);
}
```

**Signature**: Drag-and-drop kanban board mockup in hero showing realistic tasks being moved between columns.

**Layout**: Clean single-column product showcase. Alternating screenshot + feature text sections.

## Category: Gaming

### Subject: Cyberpunk RPG "Neon Ruins"
- **Audience**: Action RPG fans, cyberpunk enthusiasts
- **Job**: Drive pre-registrations
- **Mode**: Expressive + Game/Interactive

```css
:root {
  --bg: #0a0a0f;
  --surface: #111118;
  --text: #e5e5eb;
  --muted: rgba(255,255,255,0.35);
  --light: rgba(255,255,255,0.06);
  
  --neon-pink: #ff006e;
  --neon-cyan: #00f5ff;
  --neon-yellow: #ffe600;
  --neon-green: #39ff14;
  
  --gradient-hero: linear-gradient(135deg, #ff006e, #00f5ff);
  --scanline-opacity: 0.03;
}
```

**Signature**: Glitch-text title treatment with scanline overlay on the entire page, chromatic aberration on hover over key elements.

**Layout**: Cinematic full-screen hero. Character showcase as horizontal scroll. Systems specs styled as "loadout" cards.

---

### Subject: Cozy farming sim "Ember Fields"
- **Audience**: Casual gamers, Stardew Valley fans
- **Job**: Wishlist on Steam
- **Mode**: Expressive

```css
:root {
  --bg: #fdf6ec;          /* Warm cream */
  --surface: #fffdf8;
  --text: #2d2418;        /* Warm brown-black */
  --muted: #8b7a65;
  --light: #ede4d8;
  
  --primary: #e07a2f;     /* Burnt orange — harvest warmth */
  --secondary: #7cb342;   /* Earth green — crops/nature */
  --accent: #f4c542;      /* Sun yellow — happiness */
  
  --gradient-hero: linear-gradient(135deg, #e07a2f, #7cb342);
}
```

**Signature**: Animated pixel-art scene in hero that cycles through seasons (spring → summer → autumn → winter) on hover.

**Layout**: Sectioned like a storybook. Charming rounded corners. Hand-drawn-style decorative dividers.

## Category: Tech Company / Startup

### Subject: Climate tech startup "Carbon Shift"
- **Audience**: Enterprise buyers, sustainability officers, investors
- **Job**: Schedule enterprise demo
- **Mode**: Expressive

```css
:root {
  --bg: #f4f7f0;         /* Very subtle green tint */
  --surface: #ffffff;
  --text: #0f2414;       /* Deep forest green-black */
  --muted: #4a6b4a;
  --light: #dce5d8;
  
  --primary: #16a34a;    /* Forest green — sustainability */
  --secondary: #0ea5e9;  /* Sky blue — data/cloud */
  --warmth: #f59e0b;     /* Amber — action items */
  
  --gradient-main: linear-gradient(135deg, #16a34a, #0ea5e9);
}
```

**Signature**: Live CO2 counter/dashboard mockup showing "tons of carbon offset" counting upward in real-time.

**Layout**: Editorial feel with generous whitespace. Impact metrics front and center. Clean, trustworthy aesthetic.

---

### Subject: Infrastructure company "Helix"
- **Audience**: DevOps engineers, infrastructure leads
- **Job**: Read documentation, sign up for CLI
- **Mode**: Expressive

```css
:root {
  --bg: #0e0e12;
  --surface: rgba(255,255,255,0.04);
  --text: #eeeef4;
  --muted: rgba(255,255,255,0.45);
  --light: rgba(255,255,255,0.08);
  
  --primary: #8b5cf6;    /* Violet — infrastructure/deep tech */
  --accent: #06b6d4;     /* Cyan — precision engineering */
  
  --gradient-main: linear-gradient(135deg, #8b5cf6, #06b6d4);
}
```

**Signature**: Node-network particle animation in hero background showing infrastructure connections lighting up.

**Layout**: Dark theme throughout. Architecture diagrams styled as hero visuals. CLI commands as decorative elements.

## Category: Creative Agency

### Subject: Design studio "Form & Function"
- **Audience**: Potential clients, brand directors
- **Job**: Get them to browse portfolio
- **Mode**: Expressive

```css
:root {
  --bg: #f5f3ef;
  --surface: #ffffff;
  --text: #1a1a1a;
  --muted: #6b6b6b;
  --light: #e5e2dc;
  
  --primary: #dc2626;    /* Strong red — bold, confident */
  --secondary: #1a1a1a;  /* Near black — editorial gravity */
  
  --gradient-main: linear-gradient(135deg, #dc2626, #1a1a1a);
}
```

**Signature**: Horizontal scroll portfolio with large project images + minimal text overlays. Smooth momentum scrolling.

**Layout**: Editorial magazine structure. Large typography, generous margins. Each project section gets full attention.

## Category: E-Commerce / Retail

### Subject: Sustainable fashion brand "Thread & Earth"
- **Audience**: Conscious consumers, 25-40 age range
- **Job**: Browse new collection
- **Mode**: Expressive + Fashion/Luxury

```css
:root {
  --bg: #f8f6f2;         /* Natural off-white */
  --surface: #ffffff;
  --text: #1c1917;       /* Warm black */
  --muted: #78716c;
  --light: #e7e5e4;
  
  --primary: #92400e;    /* Brown/tan — natural materials */
  --secondary: #65a30d;  /* Olive — sustainability */
  --accent: #b45309;     /* Caramel — accents and CTAs */
  
  --gradient-main: linear-gradient(135deg, #92400e, #65a30d);
}
```

**Signature**: Full-bleed lookbook photography with overlay product info on hover. Seasonal color palette shifts.

**Layout**: Editorial full-bleed photography. Minimal UI chrome. Product-focused, image-heavy sections.
