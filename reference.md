# Widget snippets

Copy a snippet's HTML into a `<section>`'s `.panel`, and its `<script>` to the WIDGET SCRIPTS
area before `</body>`. Adapt the DATA block at the top of each script to the topic. Everything
is inline and dependency-free. Include the shared helper once if any heat-based widget is used.

## Robustness contract (every widget — these snippets AND anything you hand-roll)
Each widget is **its own top-level `<script>` block**, with its body wrapped in `try/catch`.
Never merge two widgets — or a widget and the template's ToC script — into one `<script>`. That
way a bug in one widget degrades only that section; the other widgets and the page's table of
contents keep working. (The snippets below show just the inner `(function(){…})()`; wrap each
one like this when you paste it.)
```html
<script>try{
  (function(){ /* widget code — DATA block at top */ })();
}catch(e){ console.error(e); }</script>
```
Then, before you open the file, confirm every DOM lookup resolves: each `getElementById('x')`,
`querySelector('.x')`, and `querySelector('[data-x]')` in your JS must match an element that
actually exists in the HTML you wrote. A lookup with no match returns `null` and the next line
throws — this is the single most common way these pages break.

## Shared helper (include once)
```html
<script>
function heatColor(t){
  t=Math.max(0,Math.min(1,t));
  const s=[[22,34,63],[77,212,196],[255,209,102],[255,107,157]];
  const seg=t*(s.length-1), i=Math.floor(seg), f=seg-i;
  const a=s[i], b=s[Math.min(i+1,s.length-1)];
  const c=a.map((v,k)=>Math.round(v+(b[k]-v)*f));
  return `rgb(${c[0]},${c[1]},${c[2]})`;
}
</script>
```

## heatmap — relationship matrix
Use for: attention, adjacency, correlation, "what relates to what".
```html
<div id="heat"></div>
<script>
(function(){
  const LABELS=["A","B","C"];                 // DATA: replace
  const M=[[.6,.3,.1],[.2,.7,.1],[.1,.2,.7]]; // DATA: rows sum ~1
  const host=document.getElementById('heat');
  const t=document.createElement('table'); t.style.borderCollapse='collapse';
  LABELS.forEach((q,i)=>{
    const tr=document.createElement('tr');
    const th=document.createElement('th'); th.textContent=q; th.style.cssText='padding:4px 8px;color:#94a3c4;font:12px ui-monospace,Menlo,monospace';
    tr.appendChild(th);
    LABELS.forEach((k,j)=>{ const td=document.createElement('td');
      td.style.cssText='width:28px;height:28px;border-radius:5px';
      td.style.background=heatColor(Math.pow(M[i][j],0.6));
      td.title=`${q}→${k}: ${(M[i][j]*100).toFixed(0)}%`; tr.appendChild(td); });
    t.appendChild(tr);
  });
  host.appendChild(t);
})();
</script>
```

## prob-bars — probabilities with a temperature slider
Use for: softmax/next-token, voting, distributions, "how confident".
```html
<label style="color:#94a3c4">temperature <span id="tv">0.8</span></label>
<input id="temp" type="range" min="0.1" max="2" step="0.1" value="0.8" style="width:160px">
<div id="bars" style="margin-top:12px;display:flex;flex-direction:column;gap:8px"></div>
<script>
(function(){
  const ITEMS=[{tk:"mat",logit:3.4},{tk:"floor",logit:2.1},{tk:"rug",logit:1.4}]; // DATA
  const bars=document.getElementById('bars'), temp=document.getElementById('temp'), tv=document.getElementById('tv');
  function softmax(xs,T){const z=xs.map(x=>x/T),m=Math.max(...z),e=z.map(v=>Math.exp(v-m)),s=e.reduce((a,b)=>a+b,0);return e.map(v=>v/s);}
  function render(){
    const T=parseFloat(temp.value); tv.textContent=T.toFixed(1);
    const ps=softmax(ITEMS.map(i=>i.logit),T);
    const rows=ITEMS.map((it,i)=>({tk:it.tk,p:ps[i]})).sort((a,b)=>b.p-a.p);
    bars.innerHTML=rows.map((r,i)=>`<div style="display:grid;grid-template-columns:90px 1fr 52px;gap:10px;align-items:center">
      <span style="text-align:right;font:14px ui-monospace,Menlo,monospace">${r.tk}</span>
      <div style="background:rgba(255,255,255,.05);border-radius:7px;height:22px"><div style="height:100%;border-radius:7px;width:${(r.p*100).toFixed(1)}%;background:linear-gradient(90deg,${i===0?'var(--hot),var(--warm)':'var(--accent),var(--accent-2)'})"></div></div>
      <span style="color:#94a3c4;font-size:13px">${(r.p*100).toFixed(1)}%</span></div>`).join('');
  }
  temp.addEventListener('input',render); render();
})();
</script>
```

## stepper — reveal stages one at a time
Use for: pipelines, algorithms, sequential processes.
```html
<div id="step" style="font-size:17px;min-height:60px"></div>
<button id="prev">‹ Prev</button> <button id="next">Next ›</button>
<script>
(function(){
  const STAGES=["Stage 1: ...","Stage 2: ...","Stage 3: ..."]; // DATA
  let k=0; const box=document.getElementById('step');
  function show(){box.textContent=STAGES[k];}
  document.getElementById('next').onclick=()=>{k=Math.min(k+1,STAGES.length-1);show();};
  document.getElementById('prev').onclick=()=>{k=Math.max(k-1,0);show();};
  show();
})();
</script>
```

## flow-diagram — labelled stages with arrows (CSS only, no JS)
Use for: architecture overviews, data flow.
```html
<div style="display:flex;gap:26px;flex-wrap:wrap">
  <!-- repeat one block per stage -->
  <div style="flex:1 1 120px;text-align:center;padding:16px 12px;border-radius:12px;border:1px solid var(--line);background:rgba(255,255,255,.02)">
    <div style="font-size:24px">🔢</div><div style="font-weight:700;font-size:14px">Stage</div>
    <div style="color:#94a3c4;font-size:12.5px">what it does</div>
  </div>
</div>
```
