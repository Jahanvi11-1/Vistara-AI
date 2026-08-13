---
name: Vistara
colors:
  surface: '#fcf8fd'
  surface-dim: '#dcd9de'
  surface-bright: '#fcf8fd'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f2f7'
  surface-container: '#f0edf2'
  surface-container-high: '#ebe7ec'
  surface-container-highest: '#e5e1e6'
  on-surface: '#1c1b1f'
  on-surface-variant: '#504538'
  inverse-surface: '#313034'
  inverse-on-surface: '#f3eff4'
  outline: '#837566'
  outline-variant: '#d5c4b3'
  surface-tint: '#83540c'
  primary: '#83540c'
  on-primary: '#ffffff'
  primary-container: '#e0a458'
  on-primary-container: '#603a00'
  inverse-primary: '#fabb6c'
  secondary: '#655975'
  on-secondary: '#ffffff'
  secondary-container: '#eddcfe'
  on-secondary-container: '#6c5f7c'
  tertiary: '#655a6d'
  on-tertiary: '#ffffff'
  tertiary-container: '#b8abc0'
  on-tertiary-container: '#483f51'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffddb8'
  primary-fixed-dim: '#fabb6c'
  on-primary-fixed: '#2a1700'
  on-primary-fixed-variant: '#653e00'
  secondary-fixed: '#eddcfe'
  secondary-fixed-dim: '#d0c0e1'
  on-secondary-fixed: '#21172f'
  on-secondary-fixed-variant: '#4d425d'
  tertiary-fixed: '#ecddf4'
  tertiary-fixed-dim: '#cfc2d7'
  on-tertiary-fixed: '#201828'
  on-tertiary-fixed-variant: '#4d4355'
  background: '#fcf8fd'
  on-background: '#1c1b1f'
  surface-variant: '#e5e1e6'
typography:
  display-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Be Vietnam Pro
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  headline-md:
    fontFamily: Be Vietnam Pro
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Be Vietnam Pro
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  xxl: 48px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 40px
---

## Brand & Style

The design system embodies an **Editorial SaaS** aesthetic, blending the structured efficiency of professional software with the sophisticated pacing of a luxury periodical. It targets discerning users who value clarity and a rhythmic, intentional interface over high-density information.

The visual style is **Minimalist with Tactile accents**, utilizing generous white space, high-quality typography, and a "layered paper" approach. The emotional response is one of calm authority—a quiet workspace that feels premium yet highly functional. Surfaces appear as soft, matte planes, avoiding harsh glares or heavy gradients in favor of subtle tonal shifts and precise linework.

## Colors

The palette is centered on a "cool meets warm" dialogue. **Lilac White** serves as the expansive primary canvas, providing a softer, more editorial feel than pure white. **Lavender Gray** is used for structural definition—demarcating cards, sidebars, and subtle dividers without creating high-contrast barriers.

**Ochre Amber** is the singular point of energy, reserved strictly for primary actions, active navigation states, and critical progress indicators. **Plum Charcoal** provides the grounding weight for typography, ensuring excellent legibility through a high-contrast but "warmer" black alternative. Risk indicators are intentionally muted to maintain the editorial harmony while remaining functionally distinct.

## Typography

The typography uses **Be Vietnam Pro** (as a high-quality alternative to Poppins that offers a more contemporary, refined geometric feel suited for SaaS). The scale is generous, favoring readability and clear hierarchy.

Headlines should be set with tighter letter-spacing to emphasize the editorial look. Body text maintains a standard 1.5x line height to ensure comfort during long-form reading or data review. Labels utilize a slight uppercase tracking to distinguish them from functional body text, acting as architectural markers within the UI.

## Layout & Spacing

This design system employs a **12-column fluid grid** for desktop and a **4-column grid** for mobile. The rhythm is dictated by an **8px linear scale**, ensuring all components align to a consistent vertical and horizontal beat.

Layouts should prioritize "contained air"—using Lavender Gray containers on Lilac White backgrounds to group related information while maintaining significant outer margins. Content density should remain low to medium; if a view becomes cluttered, utilize progressive disclosure (modals or drawers) rather than compressing the 8px spacing increments.

## Elevation & Depth

Hierarchy is achieved through **Tonal Layering** rather than traditional shadows. 
- **Level 0 (Base):** Lilac White (#F4F0F5).
- **Level 1 (Cards/Surfaces):** Lavender Gray (#B8A9C9) at 10-20% opacity or solid Lavender Gray for secondary navigation.
- **Level 2 (Interaction):** Thin, 1px Plum Charcoal outlines at 10% opacity for interactive elements.

Shadows, if used for floating elements like popovers, must be extremely diffused: `0 12px 32px rgba(62, 53, 70, 0.08)`. This creates a soft "lift" that feels atmospheric rather than physical.

## Shapes

The shape language is consistently **Rounded**, reflecting a modern and approachable SaaS personality. 
- **Standard Components:** Buttons and input fields use a `0.5rem` (8px) radius.
- **Large Containers:** Cards and primary sections use `1rem` (16px) to emphasize the editorial "block" feel.
- **Micro-elements:** Tags and checkboxes use `0.25rem` (4px) to maintain sharpness at small scales.

## Components

- **Buttons:** Primary buttons use Ochre Amber with white or Plum Charcoal text. Secondary buttons use a transparent background with a Plum Charcoal border (10% opacity).
- **Cards:** Defined by a 16px corner radius and a Lavender Gray background. In the Editorial style, cards should have generous internal padding (24px+).
- **Inputs:** Soft Lavender Gray backgrounds with a 1px border that shifts to Ochre Amber on focus. Labels sit clearly above the field in the `label-md` style.
- **Chips/Tags:** Used for "Risk" levels. These should be semi-transparent versions of the risk colors with dark text to ensure they don't overpower the layout.
- **Lists:** Clean, border-less rows separated by 1px Lavender Gray lines. High vertical padding (16px) is preferred to maintain the airy feel.
- **Navigation:** The active state is indicated by a vertical Ochre Amber bar (pill-shaped) on the leading edge of the menu item.