# CSS Component Recipes

## Button System

### Primary Button (Gradient)
```css
.btn-primary {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 16px 36px;
  background: linear-gradient(135deg, var(--purple), var(--coral));
  color: white; border: none; border-radius: 60px;
  font-weight: 600; font-size: 0.95rem;
  cursor: pointer; position: relative; overflow: hidden;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}
.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 30px rgba(124, 58, 237, 0.3);
}
.btn-primary:active { transform: scale(0.97); }
.btn-primary:focus-visible { outline: 2px solid var(--purple); outline-offset: 2px; }
```

### Secondary Button (Outlined)
```css
.btn-secondary {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 16px 36px;
  background: transparent; color: var(--text);
  border: 1.5px solid var(--text); border-radius: 60px;
  font-weight: 600; font-size: 0.95rem; cursor: pointer;
  transition: all 0.3s ease;
}
.btn-secondary:hover {
  background: var(--text); color: var(--bg);
}
```

### Ghost Button
```css
.btn-ghost {
  padding: 8px 16px; color: var(--muted);
  background: transparent; border: none; cursor: pointer;
  font-size: 0.85rem; font-weight: 500;
  transition: color 0.2s ease, background 0.2s ease;
  border-radius: 8px;
}
.btn-ghost:hover { color: var(--text); background: var(--surface); }
```

### Icon Button (Circular)
```css
.btn-icon {
  width: 48px; height: 48px; border-radius: 50%;
  border: 1.5px solid var(--light); background: transparent;
  cursor: pointer; display: flex; align-items: center; justify-content: center;
  font-size: 1.1rem; color: var(--text);
  transition: all 0.3s ease;
}
.btn-icon:hover {
  border-color: var(--text); background: var(--text); color: var(--bg);
}
```

## Card System

### Basic Card
```css
.card {
  background: var(--surface); border-radius: 20px;
  border: 1px solid var(--light);
  padding: 32px; transition: transform 0.4s ease, box-shadow 0.4s ease;
}
.card:hover {
  transform: translateY(-6px);
  box-shadow: 0 20px 50px rgba(0,0,0,0.08);
}
```

### Glass Card
```css
.card-glass {
  background: rgba(255, 255, 255, 0.06);
  backdrop-filter: blur(20px) saturate(160%) brightness(1.15);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 24px; padding: 32px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
}
```

### Featured Card (Glowing)
```css
.card-featured {
  position: relative; padding: 40px 32px;
  background: var(--surface); border-radius: 24px;
  border: 1px solid var(--light);
  transition: transform 0.3s ease, border-color 0.3s ease;
}
.card-featured::before {
  content: ''; position: absolute; inset: -1px;
  background: var(--accent-gradient); border-radius: inherit;
  z-index: -1; opacity: 0; transition: opacity 0.3s ease;
}
.card-featured:hover::before { opacity: 1; }
.card-featured:hover { transform: translateY(-8px); border-color: transparent; }
```

## Input System

### Filled Input
```css
.input-filled {
  width: 100%; padding: 14px 18px;
  background: var(--surface); border: 1.5px solid var(--light);
  border-radius: 12px; font-size: 0.95rem; color: var(--text);
  transition: border-color 0.25s ease, box-shadow 0.25s ease;
  outline: none;
}
.input-filled:focus {
  border-color: var(--purple);
  box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.15);
}
.input-filled::placeholder { color: var(--muted); }
```

### Underline Input
```css
.input-underline {
  width: 100%; padding: 10px 0;
  background: transparent; border: none;
  border-bottom: 1.5px solid var(--light);
  font-size: 1rem; color: var(--text);
  transition: border-color 0.25s ease; outline: none;
}
.input-underline:focus { border-color: var(--purple); }
.input-underline::placeholder { color: var(--muted); }
```

### Select Dropdown
```css
.select-styled {
  appearance: none; background: var(--surface);
  border: 1.5px solid var(--light); border-radius: 12px;
  padding: 14px 44px 14px 18px; font-size: 0.95rem;
  color: var(--text); cursor: pointer;
  background-image: url("data:image/svg+xml,..."); /* chevron icon */
  background-repeat: no-repeat; background-position: right 16px center;
  transition: border-color 0.25s ease;
}
```

## Navigation Components

### Desktop Nav
```html
<nav style="position:fixed;top:0;left:0;right:0;z-index:100;padding:20px 0;
  transition: background 0.35s, backdrop-filter 0.35s, box-shadow 0.35s;">
  <div class="container" style="display:flex;justify-content:space-between;align-items:center;">
    <a href="/" class="logo" style="font-weight:900;font-size:1.25rem;">
      <span style="background:linear-gradient(135deg,#7c3aed,#ec4899);
        -webkit-background-clip:text;background-clip:text;color:transparent;">STUDIO.</span>
    </a>
    <ul style="display:flex;gap:36px;list-style:none;">
      <li><a href="#work" style="font-size:0.875rem;font-weight:500;color:#6b6b6b;">Work</a></li>
      ...
    </ul>
    <a href="#contact" class="btn-primary">Let's Talk</a>
  </div>
</nav>
```

### Glass Nav on Scroll
```css
nav.scrolled {
  background: rgba(248, 247, 244, 0.75);
  backdrop-filter: blur(20px) saturate(160%) brightness(1.15);
  box-shadow: 0 1px 0 rgba(0,0,0,0.06);
}
```

### Hamburger Menu (Mobile)
```html
<button class="hamburger" aria-label="Menu" onclick="this.classList.toggle('active');
  document.getElementById('mobile-menu').classList.toggle('open')">
  <span></span><span></span><span></span>
</button>
<div id="mobile-menu" style="display:none;position:fixed;inset:0;background:#f8f7f4;
  z-index:99;flex-direction:column;align-items:center;justify-content:center;gap:32px;">
  <a href="#work" onclick="closeMobile()">Work</a>
  ...
</div>
<style>
.hamburger span { display:block;width:24px;height:2px;background:#1a1a1a;margin:5px 0;
  transition: transform 0.3s; }
.hamburger.active span:nth-child(1) { transform: rotate(45deg) translate(5px,5px); }
.hamburger.active span:nth-child(2) { opacity:0; }
.hamburger.active span:nth-child(3) { transform: rotate(-45deg) translate(5px,-5px); }
</style>
```

## Typography Components

### Section Label (Eyebrow)
```html
<p style="font-family:'JetBrains Mono',monospace;font-size:0.7rem;letter-spacing:0.08em;
  text-transform:uppercase;color:#7c3aed;margin-bottom:16px;display:inline-block;">
  Selected Work
</p>
```

### Hero Headline
```html
<h1 style="font-size:clamp(3rem,8vw,7.5rem);font-weight:900;letter-spacing:-0.04em;
  line-height:0.95;margin-bottom:28px;">
  We craft <span style="background:linear-gradient(135deg,#7c3aed,#ec4899);
  -webkit-background-clip:text;background-clip:text;color:transparent;">digital</span>
  experiences
</h1>
```

### Stat Number
```html
<div style="font-family:'Inter Tight',sans-serif;font-size:clamp(2.5rem,5vw,4rem);
  font-weight:900;letter-spacing:-0.04em;line-height:1;margin-bottom:8px;">240+</div>
<div style="font-size:0.85rem;color:#6b6b6b;">Projects Delivered</div>
```

### Monospace Data Label
```html
<span style="font-family:'JetBrains Mono',monospace;font-size:0.75rem;
  letter-spacing:0.05em;color:#6b6b6b;">EST. 2013</span>
```

## Divider & Decoration Patterns

### Horizontal Line
```html
<hr style="border:none;border-top:1px solid #e8e6e1;margin:0;" />
```

### Diagonal Section Cut
```css
.divider-diagonal::after {
  content:''; position:absolute;bottom:0;left:0;right:0;height:80px;
  background: var(--bg-color);
  clip-path: polygon(0 100%, 100% 0, 100% 100%);
}
```

### Decorative Quote Mark
```html
<p style="font-size:4rem;line-height:1;font-weight:900;
  background:linear-gradient(135deg,#7c3aed,#ec4899);
  -webkit-background-clip:text;background-clip:text;color:transparent;
  margin-bottom:12px;font-family:Georgia,serif;">"</p>
```

## Marquee / Infinite Scroll

```css
.marquee-track {
  display: flex; gap: 48px; align-items: center;
  animation: marquee 30s linear infinite; width: max-content;
}
.marquee-track:hover { animation-play-state: paused; }
@keyframes marquee {
  0% { transform: translateX(0); }
  100% { transform: translateX(-50%); }
}
```

## Gradient Background Utilities

```css
.bg-gradient-warm {
  background: linear-gradient(135deg, #7c3aed, #ec4899, #fbbf24);
}
.bg-gradient-cool {
  background: linear-gradient(135deg, #38bdf8, #7c3aed);
}
.bg-gradient-subtle {
  background: radial-gradient(circle at 20% 50%, rgba(124,58,237,0.1) 0%, transparent 50%),
              radial-gradient(circle at 80% 50%, rgba(236,72,153,0.08) 0%, transparent 50%);
}
```

## Responsive Grid Helpers

```css
/* Mobile first */
.grid-auto { display: grid; gap: 16px; }

@media (min-width: 640px) { .grid-auto { grid-template-columns: repeat(2, 1fr); gap: 20px; } }
@media (min-width: 1024px) { .grid-auto { grid-template-columns: repeat(3, 1fr); gap: 24px; } }
@media (min-width: 1280px) { .grid-auto { grid-template-columns: repeat(4, 1fr); gap: 28px; } }

/* Fluid typography */
.text-fluid { font-size: clamp(1rem, 2vw + 0.5rem, 1.5rem); }
```

## Noise Texture Overlay

```css
body::after {
  content: ''; position: fixed; inset: 0; z-index: 9999; pointer-events: none;
  opacity: 0.025;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
  background-repeat: repeat;
}
```

## Focus Styles (Accessibility)

```css
*:focus-visible {
  outline: 2px solid var(--purple);
  outline-offset: 2px;
  border-radius: 4px;
}

/* Custom for specific elements */
a:focus-visible {
  outline: 2px solid var(--purple);
  outline-offset: 4px;
  border-radius: 2px;
}

input:focus-visible, textarea:focus-visible, select:focus-visible {
  outline: none;
  box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.15);
}
```
