# Reboot Structure

This directory is the clean-slate implementation area for the new game.

Principles:

- Do not depend on legacy screen scripts.
- Keep gameplay logic, content data, and UI composition separate.
- Build for portrait mobile first.

Suggested ownership:

- `config`: app-level constants and product defaults
- `core`: shell, routing, state wiring
- `data`: declarative content tables
- `design`: visual tokens and presentation rules
- `gameplay`: rules and mechanic resolvers

The files added here are intentionally lightweight. They define the new direction
without forcing us to inherit the structure of `scripts/main.lua`.
