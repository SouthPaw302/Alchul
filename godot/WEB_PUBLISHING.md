# Play Alchul without a local installation

**Repository:** https://github.com/SouthPaw302/Alchul
**Status on 2026-11-09:** native Godot and standalone browser export both passed their GitHub Actions tests. Hosting requires a one-time GitHub Pages permission/setup action or a properly authorized hosting account. No local checkout or Godot installation is necessary for the user.

## Godot Web export — verified cloud build

- Native smoke: https://github.com/SouthPaw302/Alchul/actions/runs/42578982905 (two successful jobs).
- Web export: https://github.com/SouthPaw302/Alchul/actions/runs/42579321714 (Godot Web built and files checked).
- The export creates HTML, JavaScript, WASM and PCK resources under \`godot/build/web/\`.
- A downloadable archive named \`alchul-godot-web\` is attached to the successful Web export run. The ZIP is **not** a playable URL. It must be served through HTTP(S); opening the HTML directly from \`file://\` is not equivalent.

## Publish from GitHub Pages (preferred no-local route)

GitHub repository administrators need to enable Pages **once**.

1. Open **https://github.com/SouthPaw302/Alchul/settings/pages**.
2. Under **Build and deployment → Source**, choose **GitHub Actions**.
3. Open **https://github.com/SouthPaw302/Alchul/actions/workflows/alchul-pages.yml**.
4. Select **Run workflow** (branch \`main\`). Alternatively rerun a failed publication job if an earlier attempt failed only because Pages had not been enabled.
5. When the workflow passes, the expected browser address is **https://southpaw302.github.io/Alchul/**. Do not call the site live until the deploy action succeeds and the URL actually responds with the Godot game.

Workflow \`.github/workflows/alchul-pages.yml\` compiles fresh from Alchul, uploads the static site, and publishes via GitHub Pages using limited \`pages: write\` and \`id-token: write\` permissions. It does **not** change any unrelated repository.

Godot 4 single-threaded Web export is selected to avoid a mandatory SharedArrayBuffer / cross-origin isolation setup on GitHub Pages. Users still need a recent browser with WebAssembly + WebGL 2.0.

## Vercel alternative

\`vercel.json\` provides a build command and static output directory for Vercel. A Vercel project creation attempt through the user's connected team returned HTTP 403 (no permission to create a project). No Vercel project or URL was created, and no other Vercel project was touched. Use Vercel only if the account's project-creation permission is resolved; do not invent a deployment.

## What has and hasn't been tested

- **Verified:** Godot engine imports the native project, runs the smoke script, and exports a standalone browser bundle in CI.
- **Not yet verified:** A successfully published Pages/Vercel URL, a visual browser screenshot/gameplay session, mobile-friendly controls, polished character anatomy or a complete world.
- **No local setup required for cloud build:** GitHub Actions installs Godot and the export templates in the runner.
- **No borrowed runtime:** Only Alchul's own scenes, JSON, scripts and assets are included in the project. Official Godot is the downloadable toolchain; no other user repository is cloned.

## Reproducible build

The exact compiler command executed by CI is:

\`\`\`sh
bash godot/tools/build_web.sh
\`\`\`

The script uses official Godot 4.7.2 tools and export templates and verifies the generated HTML, JS, WASM and PCK files. See the build workflow for artifact packaging.
