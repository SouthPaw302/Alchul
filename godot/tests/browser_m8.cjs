// Batch 08: browser-level Godot preview smoke and performance probe.
// Execution: node godot/tests/browser_m8.cjs http://127.0.0.1:8765/
// Requires Playwright + its pinned Chromium. This is not an FPS certification.
const fs = require('fs');
const { chromium } = require('playwright');
const url = process.argv[2] || 'http://127.0.0.1:8765/';
const output = process.env.ALCHUL_M8_BROWSER_DIR || 'm8-browser';
fs.mkdirSync(output, {recursive:true});

const hardStop = setTimeout(()=>{console.error("ALCHUL M8 BROWSER FAIL: 90-second watchdog expired");process.exit(2);}, 90000);
async function main() {
  const browser = await chromium.launch({
    headless:true,
    args:['--enable-webgl', '--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--disable-dev-shm-usage']
  });
  const page = await browser.newPage({viewport:{width:1280,height:720},deviceScaleFactor:1});
  const fatal = [];
  const warnings = [];
  page.on('pageerror', e => fatal.push(e.message));
  page.on('console', message => {
    const txt=message.text();
    if (message.type()==='error') {
      if (/WebGL2.*not supported|wasm.*failed|abort\(|out of memory|context lost/i.test(txt)) fatal.push(txt);
      else warnings.push(txt);
    }
  });
  const response = await page.goto(url,{waitUntil:'domcontentloaded',timeout:120000});
  if(!response || response.status()!==200) throw new Error('Failed to serve Godot index.html: '+(response?.status()||'no response'));
  const webgl = await page.evaluate(()=>!!document.createElement('canvas').getContext('webgl2'));
  if(!webgl) throw new Error('Chromium SwiftShader has no WebGL2 support');
  await page.locator('canvas').first().waitFor({state:'attached',timeout:90000});
  await page.waitForTimeout(9000);
  const diagnosticProfile = await page.evaluate(()=>window.alchulM10ActiveProfile || 'not_reported');
  await page.screenshot({path:output+'/M8_GODOT_BROWSER_PREVIEW.png',fullPage:true,timeout:25000});
  const timings = await page.evaluate(()=>new Promise(resolve=>{
    let last=performance.now();const deltas=[];
    let finished=false;
    // Without a watchdog, an inactive WebGL2 canvas can hang CI indefinitely.
    const timer=setTimeout(()=>{if(!finished){finished=true;resolve(deltas);}}, 20000);
    const next=(now)=>{
      if(finished)return;
      deltas.push(now-last);last=now;
      if(deltas.length>=120){finished=true;clearTimeout(timer);resolve(deltas);}
      else requestAnimationFrame(next);
    };
    requestAnimationFrame(next);
  }));
  if (timings.length < 8) throw new Error('Browser did not deliver enough animation frames ('+timings.length+')');
  const sample=timings.slice(10).sort((a,b)=>a-b);
  const p95=sample[Math.floor(sample.length*0.95)];
  const median=sample[Math.floor(sample.length*0.5)];
  const result={software_renderer_budget_p95_ms:250,software_renderer_budget_met:Number.isFinite(p95)&&p95<=250, url,rendering_context:'Chromium headless SwiftShader/WebGL2',canvas_count:await page.locator('canvas').count(),sampled_raf_frames:sample.length,active_m10_profile:diagnosticProfile,raf_median_ms:median,raf_p95_ms:p95,console_warnings:warnings.slice(0,20),fatal_errors:fatal,disclaimer:'RAF sample measures browser scheduling in software GL CI; not a player hardware or Godot-engine FPS benchmark.'};
  fs.writeFileSync(output+'/M8_BROWSER_METRICS.json',JSON.stringify(result,null,2));
  await browser.close();
  if(fatal.length) throw new Error('Browser game raised fatal errors: '+fatal.join('; '));
  if(!Number.isFinite(p95)) throw new Error('Missing RAF timing evidence');
  if(p95>250) console.warn('ALCHUL M8 PERF GATE NOT MET on software WebGL2: p95 RAF='+p95+'ms; not cleared for production Pages');
  clearTimeout(hardStop);
  console.log('ALCHUL M8 BROWSER FUNCTIONAL SMOKE PASS; performance is separately gated',JSON.stringify(result));
}
main().catch(e=>{console.error('ALCHUL M8 BROWSER FAIL',e.stack||e.message); process.exit(1);});
