Stage 1 — Egolence Design System Install

Objective:
- Finish the dark-first design system so every remaining section can drop in without ad-hoc CSS edits.

Guiding principles:
1. Authoritative palette + tokens (colors, spacing, radii) defined once inside :root.
2. Playfair Display + Inter stacks with clear scale classes (display, lead, body, micro).
3. Layout primitives for sections, grids, cards, and 9:16 frames so hero + future sections stay consistent.
4. Buttons + CTA chips built as reusable components with hover/active states that meet contrast.
5. Responsive breakpoints at 1200 / 768 / 480 to keep typography + layout tight on mobile.
6. Existing hero/liberation/diagram selectors refactored to consume the new tokens.

Sequence:
1. Snapshot the current CSS and preserve the reset + base styling comments for reference.
2. Add :root token block (colors, spacing scale, font sizes, line heights, radii, shadows).
3. Layer typography foundations (body, headings, display classes, utility helpers).
4. Implement layout primitives (section padding, limiter widths, flex/grid helpers, card shells, media frames).
5. Build CTA + button system (primary, ghost, pill) plus inline badges for the liberation copy.
6. Wire responsive media queries that adjust typography, spacing, and grid layouts.
7. Refactor hero, liberation, and diagram sections to use the new variables + components.
8. Smoke-test the page locally to ensure no regressions before moving to Stage 2 sections.

Exit criteria:
- CSS file only contains the new tokenized system (no stray hex codes).
- Hero, liberation, diagram blocks render identically (or improved) using the shared primitives.
- Utilities exist for every upcoming section requirement (buttons, cards, proof rows, SVG frame).
