# Project context rules

These rules apply in every repository opened with this profile.

## Mandatory repository context discovery

Before making meaningful implementation decisions or editing code:

1. Read the nearest relevant `AGENTS.md` in the current repository.
2. If the repository contains `QWEN.md`, read it and treat it as mandatory architectural guidance.
3. If the repository contains local skills under `tools/skills/`, read the relevant `SKILL.md` files directly from the filesystem when the task matches them.

## Local skills vs global skills

- Use the global skill loader only for skills that are actually registered by the environment.
- Do **not** try to load repository-local skills with the global skill loader.
- For repository-local skills, use normal file reads such as:
  - `tools/skills/<skill>/SKILL.md`
  - `tools/skills/<skill>/AGENTS.md`
  - supporting assets under that skill folder

## Priority order

When guidance conflicts, use this order:

1. Explicit user instruction
2. Repository `QWEN.md`
3. Repository `AGENTS.md`
4. Relevant local skill under `tools/skills/`
5. Global skill guidance
6. Default model habits

## Practical behavior

- If the task is about NestJS best practices in a repo that has `tools/skills/goodkey-nestjs-best-practices/`, read that local skill first.
- If the task is about a specific module, read the module-specific local skill before proposing or editing code.
- If the repository has both global and local guidance, prefer the repository-local guidance.

## Git and generated assistant files

If the repo setup generates assistant-specific artifacts (for example `CLAUDE.md`, `GEMINI.md`, `.claude/skills`, `.codex/skills`, or Copilot instruction files), assume they are workflow outputs and respect the repository's gitignore policy.
