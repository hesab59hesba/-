# Motion & Animation Reference

## Animation Timing System

All animations should share a common timing language for consistency:

| Transition | Duration | Easing | Use Case |
|---|---|---|---|
| **Instant** | 0ms | — | Visibility toggles, display changes |
| **Snap** | 0.15s | ease-out | Icon state changes, micro-interactions |
| **Quick** | 0.25s | cubic-bezier(0.4, 0, 0.2, 1) | Button hover, link underline |
| **Standard** | 0.35s | cubic-bezier(0.4, 0, 0.2, 1) | Nav transitions, menu open/close |
| **Elegant** | 0.5s | cubic-bezier(0.22, 1, 0.36, 1) | Section reveals, modal dialogs |
| **Drift** | 0.8-1s | power3.out | Hero stagger, page load sequences |
| **Breath** | 2-4s | ease-in-out | Ambient floating, pulse indicators |

## Signature Animation Patterns by Category

### Software/SaaS
- **Feature reveal**: Cards slide up with stagger as user scrolls (y: 60px, opacity: 0 → 1)
- **Pricing toggle**: Monthly/Annual switch with smooth crossfade of price numbers
- **Dashboard preview**: Floating window that subtly rotates toward cursor (perspective + rotateX/Y)
- **API code snippet**: Lines appear one at a time with monospace typing effect
- **Hero background**: Slow morphing gradient mesh (CSS @keyframes 15-20s loops)

### Creative Agency
- **Portfolio scroll**: Horizontal scrolling project list pinned during vertical scroll (GSAP ScrollTrigger pin)
- **Cursor spotlight**: Gradient follows cursor position (radial-gradient at mouse x/y, updated via requestAnimationFrame)
- **Project intro overlay**: Clicking a project triggers full-screen crossfade to case study
- **Logo marquee**: Infinite horizontal scroll, pauses on hover
- **Text reveal**: Words reveal left-to-right or letter-by-letter using clip-path animation

### Gaming
- **Glitch text**: Title text with CSS clip-path glitch animation on load
- **Health/mana bars**: Gradient-filled progress bars with pulsing glow on low values
- **Scanline overlay**: CRT-style horizontal lines animated with subtle vertical drift
- **Character flip cards**: 3D card flip on hover showing front/reverse character art
- **Entry animation**: "Press Start" style countdown or beat-synced entrance sequence

### E-Commerce
- **Image zoom on hover**: Product image scales to 1.05x inside overflow-hidden container
- **Add to cart**: Button morphs into checkmark + confetti burst (particle-like CSS animation)
- **Size selector**: Pill buttons with fill animation, active state shows colored border glow
- **Color swatch**: Circular swatches with animated ring highlight, large product preview updates
- **Quick view overlay**: Product detail slides in from right side with backdrop blur

### Portfolio
- **Project filter**: Tab buttons with elastic pill indicator sliding between selections
- **Image reveal**: Photo clips from top (clip-path: inset(0 0 100% 0) → inset(0)) on scroll
- **Full-screen preview**: Clicking project expands to cover entire viewport smoothly
- **Scroll counter**: Projects viewed / total animates as user scrolls through gallery
- **Magnetic images**: Project thumbnails slightly follow cursor within constrained radius

### Fintech
- **Number counting**: Stats count up with eased animation triggered on scroll visibility
- **Chart drawing**: Line/bar charts animate their path (stroke-dasharray/stroke-dashoffset or width)
- **Balance ticker**: Numbers update with slide-up transition on change
- **Sparkline mini-charts**: SVG paths that draw themselves on page load
- **Transaction feed**: List items slide in from bottom with stagger, newest on top

## Micro-Interaction Catalog

### Hover States
| Element | Effect |
|---|---|
| Primary button | translateY(-2px) + shadow bloom with accent color |
| Card | translateY(-4px) + increased shadow spread |
| Link text | Underline grows from center (width 0 → 100%) |
| Image | Scale 1.02-1.05x inside overflow hidden container |
| Icon button | Rotate 15-45deg, scale to 1.1x |
| Nav link | Subtle color shift + dot/bullet appears before text |
| Input field | Border color transitions to accent, slight shadow |
| Select dropdown | Chevron icon rotates 180deg on open |

### Click/Active States
| Element | Effect |
|---|---|
| Button | translateY(1px) (pressed-down feel), scale 0.97x |
| Toggle switch | Knob slides with spring physics |
| Checkbox | Checkmark draws itself (SVG path animation) |
| Radio button | Inner circle fills from center |
| Tab | Active indicator pill slides to new position |

### Focus States
| Element | Effect |
|---|---|
| All interactive | Outline ring: 2px solid accent, offset 2px, border-radius matching element |
| Links | Text underlines with accent color |
| Inputs | Accent-colored border + shadow on focus |
| Buttons | Outer glow ring in accent color |

### Scroll-Based Effects
| Effect | Implementation |
|---|---|
| Reveal fade-up | IntersectionObserver sets `.in-view` class → CSS transition |
| Parallax layers | Different transform speeds per layer on scroll |
| Pin section | Container pinned while child scrolls horizontally |
| Progress bar | Fixed thin line at top, width = scrollY / documentHeight |
| Opacity sync | Element opacity decreases as it scrolls out of frame |
| Scale on scroll | Card or image scales from 0.95 to 1.0 over scroll range |

## CSS-Only Animation Recipes

### Ambient Gradient Blob
```css
.blob {
  position: absolute;
  width: 400px; height: 400px;
  background: var(--accent-color);
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.3;
  animation: blobFloat 14s ease-in-out infinite alternate;
}
@keyframes blobFloat {
  0%   { transform: translate(0, 0) scale(1); }
  50%  { transform: translate(-40px, 30px) scale(1.08); }
  100% { transform: translate(20px, -40px) scale(0.96); }
}
```

### Infinite Marquee
```css
.marquee-track {
  display: flex; gap: 48px;
  animation: marquee 30s linear infinite;
}
.marquee-track:hover { animation-play-state: paused; }
@keyframes marquee {
  0%   { transform: translateX(0); }
  100% { transform: translateX(-50%); }
}
/* Content must be duplicated exactly for seamless loop */
```

### Gradient Text
```css
.gradient-text {
  background: var(--accent-gradient);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}
```

### Spinning Conic Border
```css
@property --angle { syntax: '<angle>'; initial-value: 0deg; inherits: false; }
.spinning-border::before {
  content: '';
  position: absolute; inset: -2px;
  background: conic-gradient(from var(--angle), #6366f1, #ec4899, #a3e635, #6366f1);
  z-index: -1;
  border-radius: inherit;
  animation: spinBorder 3s linear infinite;
}
@keyframes spinBorder { to { --angle: 360deg; } }
```

### Typing/Cursor Blink Effect
```css
.typing-cursor::after {
  content: '|';
  animation: blink 1s step-end infinite;
  color: var(--accent-color);
  font-weight: 100;
}
@keyframes blink { 50% { opacity: 0; } }
```

### Pulse Glow
```css
.pulse-glow {
  animation: pulseGlow 2s ease-in-out infinite;
}
@keyframes pulseGlow {
  0%, 100% { box-shadow: 0 0 20px var(--glow-color); }
  50%      { box-shadow: 0 0 40px var(--glow-color), 0 0 60px var(--glow-color); }
}
```

### Card 3D Tilt on Mouse Move
```javascript
card.addEventListener('mousemove', (e) => {
  const rect = card.getBoundingClientRect();
  const x = (e.clientX - rect.left) / rect.width - 0.5;
  const y = (e.clientY - rect.top) / rect.height - 0.5;
  card.style.transform = `perspective(800px) rotateY(${x * 6}deg) rotateX(${-y * 6}deg)`;
});
card.addEventListener('mouseleave', () => {
  card.style.transform = '';
});
```

## GSAP ScrollTrigger Recipes

### Section Reveal on Scroll
```javascript
gsap.from('.reveal-section', {
  scrollTrigger: {
    trigger: '.section',
    start: 'top 80%',
    end: 'bottom 20%',
    toggleActions: 'play none none reverse'
  },
  y: 60,
  opacity: 0,
  duration: 0.9,
  ease: 'power3.out'
});
```

### Stagger Children
```javascript
gsap.from('.card', {
  scrollTrigger: { trigger: '.grid', start: 'top 80%' },
  y: 40,
  opacity: 0,
  duration: 0.7,
  stagger: 0.1,
  ease: 'power2.out'
});
```

### Horizontal Scroll Section
```javascript
gsap.to('.horizontal-track', {
  x: () => -(document.querySelector('.horizontal-track').scrollWidth - window.innerWidth),
  ease: 'none',
  scrollTrigger: {
    trigger: '.pin-section',
    pin: true,
    scrub: 1,
    end: () => '+=' + document.querySelector('.horizontal-track').scrollWidth
  }
});
```

### Pin + Parallel Animations
```javascript
gsap.timeline({
  scrollTrigger: {
    trigger: '.split-section',
    start: 'top top',
    end: '+=' + window.innerHeight,
    pin: true,
    scrub: true
  }
})
 .to('.left-panel', { opacity: 0, x: -40 })
 .from('.right-panel', { opacity: 0, x: 40 });
```

## Accessibility Notes for Motion

- Always wrap non-essential animations in:
  ```css
  @media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
      animation-duration: 0.01ms !important;
      animation-iteration-count: 1 !important;
      transition-duration: 0.01ms !important;
    }
  }
  ```
- Essential motion that aids understanding (transitions showing state changes) may continue
- Scroll-triggered animations should still fire but without visual delay
- Never use animation as the sole method of conveying information
- Auto-playing animations must have a visible pause/stop control
