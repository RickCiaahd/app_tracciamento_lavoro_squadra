export const STORAGE_KEY = 'squadra:v1';

export const seedData = () => ({
  version: 1,
  operators: Array.from({ length: 10 }, (_, i) => ({ id: `op-${i + 1}`, name: `Operatore ${i + 1}` })),
  activities: [
    ['pulizia', 'Pulizia', '#0f766e'], ['riparazioni', 'Riparazioni', '#e76f51'],
    ['diagnostica', 'Diagnostica', '#2a9d8f'], ['manutenzione', 'Manutenzione', '#457b9d'],
    ['qualita', 'Controllo qualità', '#8e5ea2']
  ].map(([id, name, color]) => ({ id, name, color })),
  assignments: {}
});

export function normalizeData(raw) {
  if (!raw || !Array.isArray(raw.operators) || !Array.isArray(raw.activities) || typeof raw.assignments !== 'object') throw new Error('Backup non valido');
  return { version: 1, operators: raw.operators, activities: raw.activities, assignments: raw.assignments || {} };
}

export function loadData(storage = localStorage) {
  try { const raw = storage.getItem(STORAGE_KEY); return raw ? normalizeData(JSON.parse(raw)) : seedData(); }
  catch { return seedData(); }
}

export function saveData(data, storage = localStorage) { storage.setItem(STORAGE_KEY, JSON.stringify(data)); }
export const assignmentKey = (operatorId, isoDate) => `${operatorId}|${isoDate}`;

