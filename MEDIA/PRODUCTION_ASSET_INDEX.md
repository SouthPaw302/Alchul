# Alchul production media — source index

Status: **production candidates, not approved canon**. Updated 2026-11-09.

## Authority and storage

- **One active code/world authority:** [SouthPaw302/Alchul](https://github.com/SouthPaw302/Alchul).
- **Drive source-production root:** [Alchul](https://drive.google.com/drive/folders/1EwcWrWDHsSr5KniPfhmhN2zLRmGMXANW).
- **Play in browser:** [GitHub Pages Godot runtime](https://southpaw302.github.io/Alchul/).
- **Existing archive preserved:** [explorative timeline](https://drive.google.com/drive/folders/1IemaqAs3ilJcbEXPm3WIxXXhLkmH_L0m); its city study remains historical, not approved design authority.

Drive houses high-resolution source masters and review materials. The public Godot runtime never reads Drive URLs or clones any other repository. Only validated, source-controlled assets should enter `godot/`.

## Production documents

1. [Visual Bible v0.1](https://docs.google.com/document/d/1ZbaXMo73-BQXjoAHe68XFVHauD6NoDK73gcRR20NeSA/edit) — proposed cinematic paleo-archaeological direction; not canon.
2. [Asset Roadmap and Acceptance Gates](https://docs.google.com/document/d/1hCyfm82mAGfkOQlmeeYc62BUr4lzR7pjeHM50fpmzDU/edit) — milestones M0–M5, ID-based backlog and technical/creative approval requirements.
3. [Media Pack A01 Brief](https://docs.google.com/document/d/1Wl5Ld6uJJ9tkbIKx9DRns509z30qdcdArAF-CdTgeqE/edit) — shots, exclusions and delivered candidate files.
4. [Historic Studies Index](https://docs.google.com/document/d/1932r_CPkF8RU0g1rKbpvP5ynMSwhpHqoqIKU20zRwgA/edit) — earlier city study stays in its original archive.

## A01 actual delivered candidate files

- [Riverbank composition studies and contact sheet](https://drive.google.com/drive/folders/1qNyncuklCvf0wbWJFOCs92yfp0D75IT9): **4 JPGs** (3 atmospheric sketches, 1 material contact sheet).
- [PBR material candidates](https://drive.google.com/drive/folders/12OPDBHcm-l7lOuWCCz-NJb3yhV9OJILl): **12 PNGs**, three proposed material families (silt, fractured stone, aged wood) each with albedo, tangent-space normal, roughness and height maps at 1024×1024 px.
- [Source generator, SHA-256 manifest and archive](https://drive.google.com/drive/folders/1F5G0AqOodcq9vtaLXOYui4Edw_7hJtbT): deterministic first-party Python generator, JSON checksums and complete packaged file set.
- [Single-file A01 ZIP download](https://drive.google.com/file/d/1Yx94TXpqLOD_I49ute7oRhynnyiY8UTH/view).

A01 is original procedural technical media, **not photorealistic final environment art**. Human creative review and in-Godot quality/performance tests are pending. Nothing in this source pack has been introduced into the live world as approved media.

## Media pipeline

1. Proposal and research/canon status.
2. Original art/asset generation and provenance in Drive.
3. Visual review and explicit approval; a valid file is not an approved design.
4. Import optimized files as Git-tracked resources to `godot/assets/`, with recorded original file link and SHA-256.
5. Native smoke, browser export, performance and image-quality comparison.
6. Publish only the approved scene.

**No additional Git repositories are required.** Do not touch GodRender, old browser prototypes or historical film projects as part of this production pipeline.
