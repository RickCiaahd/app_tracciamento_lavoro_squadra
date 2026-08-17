const dayMs = 86400000;
export const toIso = date => new Date(date.getTime() - date.getTimezoneOffset() * 60000).toISOString().slice(0, 10);
export const fromIso = value => new Date(`${value}T12:00:00`);
export function startOfWeek(date) { const d = new Date(date); const day = d.getDay() || 7; d.setDate(d.getDate() - day + 1); d.setHours(12,0,0,0); return d; }
export const addDays = (date, days) => new Date(date.getTime() + days * dayMs);
export function periodBounds(type, reference) {
  const d = new Date(reference); d.setHours(12,0,0,0);
  if (type === 'week') { const start = startOfWeek(d); return [start, addDays(start, 6)]; }
  if (type === 'year') return [new Date(d.getFullYear(),0,1,12), new Date(d.getFullYear(),11,31,12)];
  return [new Date(d.getFullYear(),d.getMonth(),1,12), new Date(d.getFullYear(),d.getMonth()+1,0,12)];
}
export function buildReport(data, type, reference) {
  const [start,end] = periodBounds(type, reference); const min=toIso(start), max=toIso(end);
  const byOperator = data.operators.map(operator => {
    const counts = Object.fromEntries(data.activities.map(a => [a.id,0])); let total=0; let activeDays=0;
    Object.entries(data.assignments).forEach(([key,ids]) => {
      const [op,date] = key.split('|'); if(op!==operator.id || date<min || date>max || !Array.isArray(ids)) return;
      if(ids.length) activeDays++; ids.forEach(id => { if(id in counts){counts[id]++;total++;} });
    });
    return { operator, counts, total, activeDays, percentages:Object.fromEntries(Object.entries(counts).map(([id,n])=>[id,total?n/total:0])) };
  });
  return { start, end, byOperator, totalAssignments:byOperator.reduce((n,o)=>n+o.total,0), activeOperators:byOperator.filter(o=>o.total).length };
}

