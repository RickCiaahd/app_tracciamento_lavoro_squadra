import { loadData, saveData, seedData, normalizeData, assignmentKey } from './storage.js';
import { toIso, fromIso, startOfWeek, addDays, buildReport, periodBounds } from './analytics.js';

let data=loadData(), selected=null, deferredInstall=null;
const $=s=>document.querySelector(s), $$=s=>[...document.querySelectorAll(s)];
const todayIso=toIso(new Date()); $('#weekDate').value=todayIso; $('#reportDate').value=todayIso;
const fmt=new Intl.DateTimeFormat('it-IT',{weekday:'short',day:'2-digit',month:'short'});
const esc=s=>String(s).replace(/[&<>'"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[c]));

function persist(){saveData(data);}
function toast(message){const el=$('#toast');el.textContent=message;el.classList.add('show');setTimeout(()=>el.classList.remove('show'),2200);}
function colorFor(id){return data.activities.find(a=>a.id===id)?.color||'#94a3b8';}

function renderCalendar(){
  const start=startOfWeek(fromIso($('#weekDate').value)); const days=Array.from({length:7},(_,i)=>addDays(start,i));
  let html=`<div class="calendar-row calendar-head"><div class="person sticky">Operatore</div>${days.map(d=>`<div class="day ${toIso(d)===todayIso?'today':''}"><b>${fmt.format(d).split(' ')[0]}</b><span>${fmt.format(d).split(' ').slice(1).join(' ')}</span></div>`).join('')}</div>`;
  html+=data.operators.map(op=>`<div class="calendar-row"><div class="person sticky">${esc(op.name)}</div>${days.map(d=>{const date=toIso(d),ids=data.assignments[assignmentKey(op.id,date)]||[];return `<button class="slot ${ids.length?'filled':''}" data-op="${op.id}" data-date="${date}" aria-label="${esc(op.name)}, ${date}">${ids.length?`<span class="dots">${ids.map(id=>`<i style="--dot:${colorFor(id)}"></i>`).join('')}</span><small>${ids.length} attivit${ids.length===1?'à':'à'}</small>`:'<span class="plus">+</span>'}</button>`}).join('')}</div>`).join('');
  $('#calendar').innerHTML=html;
}

function openAssignment(opId,date){
  selected={opId,date}; const op=data.operators.find(o=>o.id===opId); const chosen=new Set(data.assignments[assignmentKey(opId,date)]||[]);
  $('#dialogOperator').textContent=op?.name||''; $('#dialogDate').textContent=new Intl.DateTimeFormat('it-IT',{dateStyle:'full'}).format(fromIso(date));
  $('#activityChecks').innerHTML=data.activities.map(a=>`<label class="check"><input type="checkbox" value="${a.id}" ${chosen.has(a.id)?'checked':''}><span class="swatch" style="--swatch:${a.color}"></span><span>${esc(a.name)}</span></label>`).join('')||'<p>Aggiungi prima un’attività nelle Impostazioni.</p>';
  $('#activityDialog').showModal();
}

function saveAssignment(){if(!selected)return;const ids=$$('#activityChecks input:checked').map(i=>i.value),key=assignmentKey(selected.opId,selected.date);if(ids.length)data.assignments[key]=ids;else delete data.assignments[key];persist();renderCalendar();toast('Attività salvate');}

function renderSettings(){
  const list=(kind,items)=>items.map((item,i)=>`<div class="edit-row"><input data-kind="${kind}" data-id="${item.id}" value="${esc(item.name)}" aria-label="Nome"><button data-delete="${kind}" data-id="${item.id}" class="icon danger" aria-label="Elimina">×</button></div>`).join('');
  $('#operatorsList').innerHTML=list('operator',data.operators); $('#activitiesList').innerHTML=list('activity',data.activities);
}

function renderDashboard(){
  const type=$('#periodType').value, reference=fromIso($('#reportDate').value), report=buildReport(data,type,reference), [start,end]=periodBounds(type,reference);
  $('#summary').innerHTML=`<article class="metric card"><span>Periodo</span><strong>${start.toLocaleDateString('it-IT')} – ${end.toLocaleDateString('it-IT')}</strong></article><article class="metric card"><span>Assegnazioni</span><strong>${report.totalAssignments}</strong></article><article class="metric card"><span>Operatori attivi</span><strong>${report.activeOperators}/${data.operators.length}</strong></article>`;
  $('#charts').innerHTML=report.byOperator.map(row=>{
    const slices=data.activities.filter(a=>row.counts[a.id]).map(a=>({a,p:row.percentages[a.id]})); let cursor=0; const gradient=slices.length?slices.map(({a,p})=>{const from=cursor;cursor+=p*360;return `${a.color} ${from}deg ${cursor}deg`;}).join(','):'#e2e8f0 0deg 360deg';
    return `<article class="chart-card card"><div><h3>${esc(row.operator.name)}</h3><p>${row.total} assegnazioni · ${row.activeDays} giorni</p></div><div class="chart-body"><div class="pie" style="background:conic-gradient(${gradient})"><span>${row.total?Math.round(Math.max(...Object.values(row.percentages))*100):0}%<small>attività principale</small></span></div><div class="chart-legend">${data.activities.map(a=>`<div><i style="--dot:${a.color}"></i><span>${esc(a.name)}</span><b>${Math.round(row.percentages[a.id]*100)}%</b></div>`).join('')}</div></div></article>`;
  }).join('');
}

$$('.tabs button').forEach(b=>b.addEventListener('click',()=>{$$('.tabs button').forEach(x=>x.classList.toggle('active',x===b));$$('.view').forEach(v=>v.classList.toggle('active',v.id===b.dataset.view));if(b.dataset.view==='dashboard')renderDashboard();if(b.dataset.view==='settings')renderSettings();}));
$('#calendar').addEventListener('click',e=>{const slot=e.target.closest('.slot');if(slot)openAssignment(slot.dataset.op,slot.dataset.date);});
$('#activityForm').addEventListener('submit',e=>{if(e.submitter?.id==='saveAssignment')saveAssignment();});
$('#prevWeek').onclick=()=>{$('#weekDate').value=toIso(addDays(fromIso($('#weekDate').value),-7));renderCalendar();};
$('#nextWeek').onclick=()=>{$('#weekDate').value=toIso(addDays(fromIso($('#weekDate').value),7));renderCalendar();};
$('#todayBtn').onclick=()=>{$('#weekDate').value=todayIso;renderCalendar();}; $('#weekDate').onchange=renderCalendar;
$('#periodType').onchange=renderDashboard;$('#reportDate').onchange=renderDashboard;
document.addEventListener('click',e=>{const add=e.target.closest('[data-add]'),del=e.target.closest('[data-delete]');if(add){const kind=add.dataset.add, name=prompt(kind==='operator'?'Nome operatore':'Nome attività');if(!name?.trim())return;const item={id:`${kind}-${Date.now()}`,name:name.trim(),...(kind==='activity'?{color:['#0f766e','#e76f51','#457b9d','#8e5ea2','#f4a261'][data.activities.length%5]}:{})};data[kind==='operator'?'operators':'activities'].push(item);persist();renderSettings();}if(del&&confirm('Eliminare questo elemento?')){const kind=del.dataset.delete,id=del.dataset.id,prop=kind==='operator'?'operators':'activities';data[prop]=data[prop].filter(x=>x.id!==id);Object.keys(data.assignments).forEach(k=>{if(kind==='operator'&&k.startsWith(`${id}|`))delete data.assignments[k];else if(kind==='activity')data.assignments[k]=data.assignments[k].filter(x=>x!==id);});persist();renderSettings();renderCalendar();}});
document.addEventListener('change',e=>{const input=e.target.closest('.edit-row input');if(!input)return;const prop=input.dataset.kind==='operator'?'operators':'activities',item=data[prop].find(x=>x.id===input.dataset.id);if(item&&input.value.trim()){item.name=input.value.trim();persist();renderCalendar();}});
$('#exportBtn').onclick=()=>{const blob=new Blob([JSON.stringify(data,null,2)],{type:'application/json'}),a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download=`squadra-backup-${todayIso}.json`;a.click();URL.revokeObjectURL(a.href);};
$('#importInput').onchange=async e=>{try{data=normalizeData(JSON.parse(await e.target.files[0].text()));persist();renderCalendar();renderSettings();toast('Backup importato');}catch(err){alert(err.message);}};
$('#resetBtn').onclick=()=>{if(confirm('Cancellare i dati locali e ripristinare l’esempio?')){data=seedData();persist();renderCalendar();renderSettings();toast('Dati ripristinati');}};
window.addEventListener('beforeinstallprompt',e=>{e.preventDefault();deferredInstall=e;$('#installBtn').classList.remove('hidden');});$('#installBtn').onclick=async()=>{await deferredInstall?.prompt();deferredInstall=null;$('#installBtn').classList.add('hidden');};
if('serviceWorker' in navigator)navigator.serviceWorker.register('./sw.js');
renderCalendar();

