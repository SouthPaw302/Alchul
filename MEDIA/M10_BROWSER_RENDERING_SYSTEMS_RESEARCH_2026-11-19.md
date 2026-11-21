# ALCHUL — Browser Rendering Systems Research and Decision Record

**Date:** 2026-11-19  
**Status:** Engineering research; candidate recommendation, not a canon or release approval  
**Target:** The actual Godot 4 WebGL 2 Compatibility renderer in this repository, not hypothetical native Vulkan features.

## Executive decision

**Keep the existing Godot 4 project as the primary game/experience while optimizing the Compatibility rendering path; evaluate a small isolated PlayCanvas or Three.js prototype only if GPU-backed browser benchmarks demonstrate that Godot is the enduring limiting factor.** Do not replace the historical-world engine based on slow headless SwiftShader tests alone.

The immediate investigation should focus on the directional light's shadow map. Current PR-only single-pass CI experiments found that disabling shadows reduced **SwiftShader RAF p95 from 999.9ms to 666.6ms** and reducing shadow work *alongside* the M6 and water shaders yielded 533.4ms. These were one-pass trials with unequal, small frame counts, so they identify a lead rather than proven general-purpose gains. Other isolated trials: simplified M6 procedural fragment noise yielded 1383.3ms (worse), static water yielded 816.7ms. None met the project 250ms software renderer budget. This is **not hardware FPS**.

Proof: https://github.com/SouthPaw302/Alchul/actions/runs/44380241486

## 1. What was actually built and validated

- Main branch uses Godot 4 Compatibility/WebGL2 and remains unchanged by this research.
- PR #3 merged-source **candidate only** combines 3,556 original static opaque mesh instances into 102 material/bucket groups, conserving 321,676 authored triangles. Native Godot 10-shot A/B mean rendering draw calls: 8,454.1 to 580.3, and screenshot diffs passed a review threshold. These values measure native OpenGL Compatibility renderer under a virtual display, not browser real GPU FPS.
- The browser smoke uses Playwright Chromium forced to `--use-angle=swiftshader`, which renders entirely in software on the host CPU. It measures page-level `requestAnimationFrame` intervals for a small sample, not direct Godot render-thread/GPU timings.
- One 1280x720 Godot Web export in this PR contains roughly 38MB uncompressed WebAssembly and a 12MB resource pack. Network compression affects first load rather than inner-frame runtime.
- PR-only browser URL variants isolate daylight shadows, expensive procedural M6 noise, and animated water. The default remains full quality.

## 2. Primary browser system: optimized Godot Compatibility / WebGL2

**Compatibility boundary.** Godot 4 Web export requires WebGL 2 and the Compatibility renderer, not native Forward+ or Mobile renderer. There is not a supported switch that enables the native Vulkan or Forward+ pipeline within Godot 4 Web export. Godot docs: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html

**Why batching helped.** The Compatibility renderer does **not** implement the automatic Forward+ mesh instancing feature. Manual static mesh merging and MultiMesh instancing matter in this target. Batching must retain material coherence and visibility regions, because a large combined mesh is culled as a whole. Existing PR uses 24m regions for background trees. Sources:
- https://docs.godotengine.org/en/stable/tutorials/performance/optimizing_3d_performance.html
- https://docs.godotengine.org/en/stable/tutorials/performance/using_multimesh.html
- https://docs.godotengine.org/en/stable/tutorials/performance/gpu_optimization.html

**Highest-priority next graphics experiments (keep visual quality):**

1. **Directional shadow detail and coverage.** Compare 4-split vs 2-split/orthogonal modes where supported, shorter effective shadow distance, smaller shadow atlas, and restrict low-impact meshes from casting shadows. Preserve real visible canopy shadows within the visitor's walking area. Document color/contrast differences between shadow modes. Godot explains that PSSM shadow splits may increase draw calls, and shadows are computed in extra passes; static shadowmap size is an important cost variable. Source: https://docs.godotengine.org/en/stable/tutorials/3d/lights_and_shadows.html
2. **LOD and culling.** Use visibility ranges, automatic imported mesh LOD, or explicitly authored lower-detail habitat flora beyond nearby observation distances. Keep surface-era architecture correct at close range; never replace scientific anatomy with generic humanoids. Source: https://docs.godotengine.org/en/stable/tutorials/3d/visibility_ranges.html
3. **Distance-based materials.** Reduce distant normal-map/shader complexity only when it produces no visible quality regression at normal viewing size; use fewer shader variants. Pixel shading and texture bandwidth can dominate the GPU. Source: https://docs.godotengine.org/en/stable/tutorials/performance/gpu_optimization.html
4. **Baked lighting, conditional feasibility.** Research LightmapGI for genuinely static architecture and bank structures, keeping animated river and inhabitants dynamic. It requires suitable UV2/lightmap unwrapping; our original M2 GLB lacked even base UV and M6's UV geometry is not yet fully tracked, so this is **a modeling/import task**, not a checkbox. Godot Compatibility can *render pre-baked lightmaps* but baking must be performed on supported nonweb hardware. Sources:
   - https://docs.godotengine.org/en/stable/tutorials/3d/global_illumination/using_lightmap_gi.html
   - https://docs.godotengine.org/en/stable/classes/class_lightmapgi.html
5. **Transparent surfaces.** Preserve blend sort for water; minimize overlapping alpha-blended surfaces because they impair depth optimization and require back-to-front rendering. Source: https://docs.godotengine.org/en/stable/tutorials/performance/gpu_optimization.html
6. **Delivery and first load.** Configure hosting cache/compression and measure real first contentful/first playable time. Godot recommends gzip/Brotli for large .wasm and .pck; GitHub Pages supports gzip. Do **not** count compression as a remedy for ongoing 1s RAF timing. Source: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html

## 3. Other systems researched as possible web-first viewer

| System | Actual web backend | Advantages to ALCHUL | Real migration cost / decision |
|---|---|---|---|
| **Godot 4 Compatibility** (current) | WebGL2 + WebAssembly | Already has worldbook, visitor movement, HUD/lenses, terrain, scene and test automation | Best short-term: optimize shadows/LOD/texture data; keep current repo and working mechanics |
| **PlayCanvas Engine** | WebGL2 by default; WebGPU beta with fallback | Browser-first loading/profiling, PBR, static/dynamic batching, instancing, lightmaps, 3D assets/GLB; possible strong alternate view-only renderer | Would require new scene graph, procedural settlement recreation, input/story controls, validation and release process. Do **not** claim it is faster before a matched benchmark. |
| **Three.js WebGLRenderer / WebGPURenderer** | Mature WebGL2; experimental WebGPU backend with WebGL2 fallback | Flexible browser-first custom viewer with direct control of render loop; import original GLBs and render 10 identical camera shots | Requires rebuilding Godot movement, materials, terrain, shaders, HUD and interaction, plus custom QA. Modern WebGPU renderer has shader/postprocess migration considerations. |

PlayCanvas:
- https://developer.playcanvas.com/user-manual/graphics/
- https://developer.playcanvas.com/user-manual/optimization/
- https://developer.playcanvas.com/user-manual/engine/supported-browsers/

Three.js:
- https://threejs.org/manual/pages/webgpurenderer
- https://threejs.org/docs/pages/WebGLRenderer

**Do not assume** a WebGPU port is automatically faster: on real devices, API overhead, scene organization, shader complexity and supported browser/driver all matter. Compare small representative scenes on the same physical GPU before considering a pivot.

## 4. Critically: the existing browser benchmark is not a hardware-performance assessment

The ALCHUL Playwright script explicitly enables Chromium SwiftShader. Chromium describes SwiftShader as a CPU software implementation of graphics APIs, used on hosts without a GPU. Thus it is useful for a continuous-integration *functional compatibility* smoke check and for exploratory same-run comparative shader tests, but it cannot certify a normal player's experience. Reference: https://chromium.googlesource.com/chromium/src/+/main/docs/gpu/swiftshader.md

A robust production assessment needs:
1. **Hardware-backed browser** Chrome/Edge (and Firefox/Safari where supported), recording actual WebGL renderer identity to confirm no software fallback.
2. At least 60 seconds after warmup at 10 repeated viewpoint/camera scenes. Record medians, p95 and low-percentile frame timing, frame hitches, CPU/memory, loading time and device pixel ratio. Repeat three times per variant and on two device tiers. These are proposed measurement parameters, not numbers already collected.
3. Godot `RenderingServer` draw calls and triangles, Godot profiler when available, browser Performance panel, screenshots, visible shadow fidelity, input interaction, and context-loss detection.
4. Native Godot render and browser WebGL2 **separate** acceptance gates; responsive fallback settings for weaker devices, rather than requiring rich 3D to achieve an arbitrary SwiftShader-only p95 budget at all costs.
5. Preserve the unchanged full-fidelity version and reject any optimization with major camera-view artifacts.

Official method guidance:
- https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html
- https://developer.chrome.com/docs/devtools/performance/overview/
- https://developer.playcanvas.com/user-manual/optimization/troubleshooting-performance/

## 5. Next numbered execution sequence

1. Add a **four-way shadow-quality A/B** to PR #3 (unchanged reference, short shadow distance, lower shadowmap resolution, limited shadow casters), with before/after ten native visuals.
2. Enhance the browser harness to record renderer name, frame count, viewport size, launch/warmup, and min/max; repeat 3 runs of each mode when CI budget permits.
3. Implement near/far vegetation LOD and visibility ranges in a separate review branch; retain exact geometry/provenance and 10 visual QA angles.
4. Inspect the 28 source PNG material families to ensure texture import and mipmap/normal-map settings work efficiently in WebGL2. Preserve source image hashes.
5. Prototype a **single GLB** in PlayCanvas or Three.js only if the hardware benchmark shows a sustained engine limitation; compare matched images and interactions, not marketing claims.
6. Merge M9 then M10 only after tested results and explicit release review; the existing site is not a current PR preview.

**Release decision:** No browser-first engine migration is justified by the existing measurements alone. Main site not updated by this research.
