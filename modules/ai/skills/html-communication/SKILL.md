---
name: html-communication
description: Create self-contained HTML explanations, plans, comparisons, and reports when the user asks for HTML or when visual structure and interaction would make a complex answer easier to understand. Keep simple answers in chat. Website implementation and HTML email use their own workflows.
---

# HTML communication

Use an HTML document to help the reader understand a subject or make a decision.
Choose the structure around the reader's question, not a generic dashboard layout.

## Shape the explanation

Infer the audience and purpose from the conversation. Ask only when a missing
detail would materially change the content. Honor an explicitly requested format.

Lead with the main finding, recommendation, or question the document answers.
Follow it with the evidence and explanation the reader needs. Keep assumptions,
unknowns, and illustrative data distinct from verified facts. Link sources beside
the claims they support, and preserve units and dates when presenting data.

Choose visuals that carry meaning:

- Use diagrams for relationships, sequences, and data flow.
- Use tables for comparisons across consistent criteria.
- Use charts for quantities and trends, with labeled axes and units.
- Use timelines for order and dependencies, distinguishing estimates from commitments.

Add interaction when it helps the reader explore the subject. Filters, scenario
controls, and expandable detail must change or reveal useful information. Keep
the main conclusion visible without requiring interaction.

## Build the document

Default to one `.html` file with inline CSS, inline SVG, and only the JavaScript
the explanation needs. Make the document work when opened locally, without a
build step, server, or network connection. Use system fonts and embed required
assets. Source links may point to the web.

Use semantic headings, a readable text width, and spacing that reflects the
content hierarchy. Adapt the layout to narrow screens. Keep wide tables and code
blocks in their own scrollable containers. Provide text explanations for diagrams
and charts, sufficient contrast, labeled controls, and visible keyboard focus.
Respect reduced-motion preferences when using animation.

Keep core content readable with JavaScript disabled. Use print styles when the
document is likely to be shared or printed, and include essential expanded detail
in the printed version. Escape source text before inserting it into HTML. Use
`textContent` for dynamic text from user input or external data.

Save the file in the user's requested location. Otherwise create a temporary
directory with `mktemp -d "${TMPDIR:-/tmp}/html-communication.XXXXXX"` and save
`<descriptive-name>.html` there. Keep the file available after delivery.
When revising a document, preserve its path unless the user wants a separate version.

## Verify and deliver

Open the actual file with an available browser tool and inspect the rendered
document at wide and narrow widths. Exercise each control and check keyboard
navigation, links, and diagram labels. Check print output when print styles matter.
Fix clipping, overflow, broken assets, and interaction errors before delivery.

If browser inspection is unavailable, check the source and any JavaScript with
available tools. State that the rendering remains unverified.

Return a clickable link to the HTML file with a short summary of its main point.
Keep the artifact local unless the user asks to publish or send it.
