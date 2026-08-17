import test from 'node:test';import assert from 'node:assert/strict';import {periodBounds,buildReport,toIso} from '../analytics.js';
test('calcola i confini mensili',()=>{const [a,b]=periodBounds('month',new Date(2026,1,12,12));assert.equal(toIso(a),'2026-02-01');assert.equal(toIso(b),'2026-02-28');});
test('conta più attività nella stessa giornata',()=>{const data={operators:[{id:'o1',name:'Mario'}],activities:[{id:'a',name:'A'},{id:'b',name:'B'}],assignments:{'o1|2026-02-03':['a','b'],'o1|2026-02-04':['a']}};const r=buildReport(data,'month',new Date(2026,1,12,12));assert.equal(r.totalAssignments,3);assert.equal(r.byOperator[0].activeDays,2);assert.equal(r.byOperator[0].percentages.a,2/3);});

