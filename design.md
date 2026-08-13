# Vistara — Design System & Product Specification

**AI-Powered Contract Risk Analysis Platform**
Tagline: *"Understand your contract before it becomes a problem."*

---

## 1. Product Positioning

**Name:** Vistara
**Description:** Vistara uses AI to identify potentially risky clauses in contracts and explain what they could mean in simple language.

**What it is NOT:** a document summarizer. Vistara identifies *individual clauses* that deserve attention, classifies their risk, highlights them in the original document, explains them in plain language, and shows a realistic consequence scenario.

### Brand feel
Trustworthy · Intelligent · Calm · Sophisticated · Modern · Approachable · Editorial · Privacy-conscious · Professional (not law-firm) · Technologically advanced (not futuristic)

### Explicitly avoid
Generic legal-tech dashboard · cybersecurity product · chatbot · banking app · corporate enterprise tool · neon AI interface · generic "AI assistant with a chat box"

### Reference blend
**Medium** (editorial sophistication) + **Figma** (structured workspace) + modern SaaS product design — never copied directly, always synthesized into an original Vistara identity.

---

## 2. Design Philosophy

| Influence | Bring in |
|---|---|
| **Editorial (Medium)** | generous whitespace, excellent typography, readable document presentation, calm hierarchy, restrained color, strong type scale |
| **Modern SaaS (Figma)** | structured nav, clean sidebar, workspace organization, panels/cards, contextual controls, polished interactions, clear IA |

Overall impression: **"Quietly intelligent."**

---

## 3. Color System — Lavender-Gray & Ochre

A cool, muted lavender-gray paired with a warm ochre accent. Reads as sophisticated and slightly unconventional without leaning purple/pink, blue, green, or brown.

### Brand palette

| Token | Hex | Role |
|---|---|---|
| Lilac White | `#F4F0F5` | Primary page/background |
| Lavender Gray | `#B8A9C9` | Secondary surfaces, cards, selected states, subtle backgrounds |
| Ochre Amber | `#E0A458` | Primary brand accent — CTAs, active nav, highlights, emphasis |
| Plum Charcoal | `#3E3546` | Primary text (replaces pure black), strong headings |

**Usage notes:**
- `#F4F0F5` is the dominant surface — keep large areas of the UI in this tone so the palette reads calm, not saturated.
- `#B8A9C9` is for containment: cards, panel backgrounds, hover/selected states, dividers at reduced opacity.
- `#E0A458` is used sparingly — primary buttons, active nav indicator, key highlights, small accent details. Overuse will make the UI feel decorative rather than sophisticated.
- `#3E3546` is text and high-contrast UI chrome — never pure black, keeps warmth consistent with the rest of the palette.
- For secondary/muted text, derive a lighter tint of Plum Charcoal (e.g. `#6E6478`) rather than introducing a new gray.

### Risk color system (kept separate from brand palette, but harmonized in tone/saturation)

| Risk | Treatment | Use for |
|---|---|---|
| **High** | Muted brick red `#B15E56` | high-risk clauses, critical warnings, high scores |
| **Medium** | Muted amber/gold `#C98A3E` (distinct from brand ochre in context/label, not just color) | medium-risk clauses, moderate warnings |
| **Low** | Muted olive-taupe `#9C9268` | low-risk clauses, safe indicators |
| **Neutral** | Warm gray `#8A8290` | normal document text, inactive elements |

Never rely on color alone — always pair with a text label (e.g. **HIGH RISK**).

---

## 4. Typography

**Primary typeface:** Poppins (throughout)

| Element | Weight |
|---|---|
| Hero headings | Bold / Semi-bold |
| Page headings | Semi-bold |
| Section headings | Medium / Semi-bold |
| Body | Regular |
| Metadata | Regular / Medium |
| Buttons | Medium / Semi-bold |
| Risk labels | Medium / Semi-bold |

Keep the weight palette restrained; prioritize spacious, highly readable type.

---

## 5. Design Language

**Use:** rounded (not playful) cards · subtle borders · very soft shadows · generous spacing · large whitespace · clean grid alignment · minimal iconography · 8px spacing system · restrained corner radius · editorial document surfaces · subtle hover states · polished transitions.

**Avoid:** gradients (excessive) · glassmorphism · neon · huge floating blobs · excessive illustration · pill-heavy UI · emoji-heavy UI · cluttered dashboards.

---

## 6. Logo / Brand Mark

- Text-based **Vistara** wordmark, set in Plum Charcoal (`#3E3546`) with an ochre accent detail.
- Minimal abstract symbol evoking: seeing / clarity / a lens / a prism / revealing hidden information.
- **Never use:** shields, checkmarks, courthouse icons, gavels, scales of justice, generic AI stars.
- Must scale down cleanly to: sidebar logo, mobile header, favicon/app icon, report header.

---

## 7. Information Architecture — Web

Left sidebar (compact, elegant, spacious, `#F4F0F5` or `#B8A9C9` background):

```
Vistara
──────────────
Home
Dashboard
New Analysis
Recent Documents
Reports
Settings
──────────────
Help
Privacy
[small Vistara branding]
```

Active nav item: subtle ochre accent treatment (underline, left bar, or soft ochre-tinted background) — never an aggressive solid block.

---

## 8. Web Screens

### 8.1 Home (landing/dashboard hybrid)
- Hero: **"Understand your contract before it becomes a problem."**
- Subcopy: *Vistara identifies potentially risky clauses, explains them in plain language, and helps you understand what deserves your attention before you agree.*
- Primary CTA: **Analyze a Document** (ochre fill)
- Secondary CTA: **View Recent Documents** (outline / lavender-gray fill)
- Large upload card — **Analyze your document**
  - Upload PDF (drag/drop — "Drop your PDF here", "PDF files supported")
  - or Paste Text
- "How Vistara works": Upload → Analyze → Understand → Decide (minimal visual treatment)
- Disclaimer: *Vistara provides AI-powered educational risk analysis, not legal advice. Results may be incomplete or inaccurate.*

### 8.2 Dashboard
- Header: **Good morning** / **What would you like to understand today?**
- Primary action: **+ New Analysis** (ochre)
- Stat cards (lavender-gray surface): Total Documents (12) · High Risk Found (8) · Reports Generated (7)
- Recent Documents list — each row: doc icon, name, date, risk score, risk level, Open button
  - Apartment Lease — 78/100 — High Risk
  - Freelance Agreement — 62/100 — Medium Risk
  - Student Loan Agreement — 71/100 — High Risk

### 8.3 New Analysis
- Header: **New Analysis** / *Upload a document and let Vistara identify the terms that deserve your attention.*
- Upload PDF (drag/drop) or Paste Text (large textarea)
- Primary button: **Analyze Document** (ochre)
- Supported file info + privacy note: *Your document is used to generate this analysis.* (no offline-processing claims)

### 8.4 Processing State
Staged progress, not a bare spinner:
```
Analyzing your document
✓ Reading document
✓ Identifying clauses
● Evaluating potential risks
○ Preparing explanations
```
Show live count: **Analyzing 47 clauses.** Use ochre for active/checked states. Subtle motion only.

### 8.5 Risk Overview (post-analysis summary)
- Header: **Apartment Lease** / *Analyzed August 13, 2026*
- Large score: **78 / 100** — label **HIGH RISK** (brick-red)
- Horizontal risk meter (brick-red → amber-gold → olive-taupe segments)
- Breakdown: 3 High · 5 Medium · 14 Low
- "What deserves your attention" — top 3 clickable findings on lavender-gray cards:
  - Auto-Renewal — High Risk — Page 5
  - Early Termination — High Risk — Page 7
  - Liability Waiver — High Risk — Page 9
- Primary CTA: **Review Contract** (ochre) · Secondary: **Download Risk Report**

### 8.6 Main Document Workspace (core screen)
Figma-inspired split layout:
- **Left:** document workspace — realistic contract typography inside a calm, `#F4F0F5`-toned surround (not full-screen PDF). Page nav, zoom, fit-to-page, prev/next.
- **Right:** analysis panel (see 8.7)
- Highlights = translucent text highlighting (never solid blocks): brick-red (high) / amber-gold (medium) / olive-taupe (low)

### 8.7 Right Analysis Panel
**Default state (nothing selected):**
- Risk Summary — 78/100, 3 High / 5 Medium / 14 Low
- Top Findings list

**Clause selected:**
```
HIGH RISK
Auto-Renewal — Page 5

Original clause
[contract text]

What does this mean?
[1–2 plain-language paragraphs]

Why is it risky?
• Creates an automatic obligation
• Requires advance notice
• Missing the deadline may trigger renewal terms

Confidence: 94%  [subtle ochre indicator]

[See What Could Happen →]
```

### 8.8 Scenario Panel
Triggered by "See What Could Happen":
- Title: **What could happen?**
- Concise, contract-grounded scenario (e.g. *"You forget to provide notice before the deadline. The lease may continue according to the renewal terms described in the agreement."*)
- No invented monetary figures
- Note: *This is an illustrative scenario, not a prediction or legal conclusion.*

### 8.9 Download Report
- Button: **Download Risk Report** (ochre)
- Generation state:
```
✓ Findings collected
✓ Explanations added
✓ Risk summary prepared
✓ Report ready
```
- Actions: **Open Report** · **Download PDF**
- Report contents: Vistara branding, contract name, date, overall score, risk breakdown, top risks, original clause, plain-English explanation, why it matters, scenario, disclaimer.

### 8.10 Recent Documents
- Search bar: **Search documents**
- Filters: All / High Risk / Medium Risk / Low Risk (ochre active-filter state)
- Rows/cards with name, score, risk level, date → opens saved local analysis. No login/accounts.

### 8.11 Reports
Simple history list: document name, date, score, risk level, View, Download.

### 8.12 Settings
- **Preferences:** Theme, Notifications
- **Privacy:** *Your recent document history is stored locally on this device/browser.* → **Clear Recent Documents**
- **About:** Vistara version
- **Disclaimer:** full legal/educational disclaimer
- No authentication screens.

---

## 9. Mobile Application

Bottom navigation: **Home · Analyze · Recent · Reports · Settings** (active tab in ochre)
Compact header with Vistara wordmark on `#F4F0F5`. More whitespace + editorial type than desktop — **not** a shrunken desktop layout.

### 9.1 Home
Logo header → hero copy → primary card **"Analyze a document"** (Upload PDF / Paste Text) → Recent Documents as cards.

### 9.2 Analysis Overview
```
Apartment Lease
78 / 100
HIGH RISK

3 High · 5 Medium · 14 Low
(brick-red / amber-gold / olive-taupe indicator dots — no emoji in final UI)

Pay attention to
[top 3 risk cards]

[Review Contract]
[Download Report]
```

### 9.3 Document Viewer (core mobile experience)
- Vertical scroll of the real contract page
- Subtle translucent highlights on risky clauses
- Persistent compact footer: **3 High · 5 Medium · 14 Low**
- No permanent side-by-side explanation panel (insufficient width)

### 9.4 Clause Interaction — Bottom Sheet
Tapping a highlighted clause opens a **bottom sheet** (never a full navigation to a new page) on `#F4F0F5`/`#B8A9C9` surface. Selected clause stays visible above the sheet and remains highlighted.

```
[drag handle]
HIGH RISK
Auto-Renewal

Original clause
[text]

What does this mean?
[paragraph]

Why is it risky?
• bullet
• bullet
• bullet

Confidence: 94%
[See What Could Happen]  (ochre button)
```

### 9.5 Scenario (expanded sheet)
```
What could happen?
Contract condition → User action → Possible consequence
```
Note: *Illustrative scenario based on the analyzed clause.* No invented financial figures.

### 9.6 Recent Documents
Vertically stacked cards (name, score, risk level, date) → tap to reopen. Framed as local device/browser history, no login.

### 9.7 Report
Sections: risk score, breakdown, top findings, clause explanation, scenario, disclaimer.
Primary: **Download PDF** (ochre) · Secondary: **Share**

### 9.8 Settings
Preferences (Theme) · Privacy (local history, **Clear Recent Documents**) · About · Disclaimer. No login/signup/profile/account screens.

---

## 10. Empty States
```
No documents yet
Your analyzed documents will appear here.
[Analyze your first document]
```
Subtle Vistara visual elements only (e.g. faint ochre lens motif) — no generic illustrations.

---

## 11. Error States

| Case | Message |
|---|---|
| Unsupported file | *This file type isn't supported. Please upload a PDF.* |
| Empty text | *Please paste some contract text before analyzing.* |
| Analysis failure | *We couldn't analyze this document. Please try again.* — CTA: **Try Again** |

Tone: calm and helpful, never alarming. Error accents use brick-red sparingly, not the full risk-red saturation.

---

## 12. Disclaimer Language

**Full:** *Vistara provides AI-powered educational risk analysis, not legal advice. AI-generated results may be incomplete or inaccurate and should not be relied upon as a substitute for advice from a qualified legal professional.*

**Short (near analysis UI):** *ⓘ AI risk analysis — not legal advice.*

Must appear in: Home/upload area · Analysis experience · Settings · Downloaded report. Integrated elegantly (small type, muted plum-gray tone) — never disruptive or alarming.

---

## 13. Sample Contract Content

Fictional apartment lease with clauses covering: Auto-renewal, Early termination, Liability waiver, Hidden fees, Unilateral modification. Realistic page/clause numbering; no real personal data.

---

## 14. Responsive Behavior

| Breakpoint | Behavior |
|---|---|
| **Desktop** | persistent left sidebar, large document workspace, right analysis panel, generous horizontal space |
| **Tablet** | collapsible sidebar, document-centered layout, analysis panel becomes a drawer |
| **Mobile** | bottom nav, document-first, bottom sheet for clause explanations, touch-friendly controls |

Never simply scale the desktop layout down — each breakpoint is designed intentionally.

---

## 15. Accessibility

- Readable contrast throughout — verify Plum Charcoal (`#3E3546`) on Lilac White (`#F4F0F5`) and on Lavender Gray (`#B8A9C9`) both meet WCAG AA for body text.
- Ochre (`#E0A458`) on white/lilac backgrounds needs sufficient weight/size or a darker shade for small text — reserve pure ochre for large text, icons, and fills with dark text/labels on top.
- Large touch targets
- Clear typography
- Risk communicated via **text label + color**, never color alone
- Clear button labels
- Visible interactive states (hover/focus/active)

---

## 16. Micro-interactions

Document upload · analysis progress · risk score counting up · clause highlight appearing · bottom sheet sliding up · selected clause focus · report generation · hover states · button transitions.

All motion: subtle and calm — never excessive or futuristic. Ochre used for active/in-progress motion cues.

---

## 17. Out of Scope for Current MVP

Do **not** design or add placeholder nav for:
image upload · camera scanning · Chrome extension · offline/on-device AI agent · community/forum · multilingual support · speech-to-text · text-to-speech · negotiation assistant · user accounts · authentication · cloud profile · blockchain · payments.

The MVP should feel intentionally focused, not padded with future-feature placeholders.

---

## 18. Core Product Flow

```
UPLOAD
  ↓
ANALYZE
  ↓
RISK OVERVIEW
  ↓
OPEN DOCUMENT
  ↓
SEE HIGHLIGHTED CLAUSES
  ↓
TAP A RISK
  ↓
UNDERSTAND THE CLAUSE
  ↓
SEE WHY IT MATTERS
  ↓
SEE WHAT COULD HAPPEN
  ↓
DOWNLOAD RISK REPORT
```
This flow is the heart of the product — every screen should serve it.

---

## 19. Guiding Product Principle

Vistara is **not** a summarizer. The primary visual experience is always:

**Original document + risk heatmap + contextual explanation.**

A user should be able to answer *"Which parts of this document deserve my attention?"* within seconds.

---

## 20. Final Visual Goal

A premium, launch-ready product blending:

**Medium's calm editorial reading experience + Figma's structured workspace + modern AI SaaS design**, expressed through Vistara's own **Lilac White · Lavender Gray · Ochre Amber · Plum Charcoal** identity.

Target qualities: minimal, intelligent, editorial, trustworthy, warm, sophisticated, modern, highly usable. Every screen has one obvious primary action. Web and mobile must read as one coherently designed product, not generated screens stitched together.
