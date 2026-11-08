// End-to-end API smoke test for UC27, UC29, UC32, UC37, UC38.
// Requires: fresh seed data (database/01_schema.sql + 02_seed.sql) and the API running on :4000.
// Run:  node test/smoke-test.mjs        (it MODIFIES data – reload the seed afterwards)
const API = process.env.API ?? 'http://localhost:4000/api';
let pass = 0, fail = 0;

async function call(token, method, path, body) {
  const res = await fetch(API + path, {
    method, headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  });
  const data = await res.json().catch(() => ({}));
  return { status: res.status, data };
}
function check(name, cond, extra = '') {
  if (cond) { pass++; console.log(`  ✔ ${name}`); } else { fail++; console.log(`  ✘ ${name} ${extra}`); }
}
async function login(email) {
  const r = await call(null, 'POST', '/auth/login', { email, password: 'Password@123' });
  if (r.status !== 200) throw new Error(`login ${email} failed: ${JSON.stringify(r.data)}`);
  return r.data.accessToken;
}
const expectStatus = async (name, p, code) => { const r = await p; check(`${name} → ${code}`, r.status === code, `(got ${r.status}: ${r.data.message})`); return r; };

const rec = await login('reception1.cg@autocare.vn');
const recHD = await login('reception1.hd@autocare.vn');
const m1 = await login('mechanic1.cg@autocare.vn');     // staff 6
const m2 = await login('mechanic2.cg@autocare.vn');     // staff 7
const cashier = await login('cashier.cg@autocare.vn');

console.log('\nAuth');
await expectStatus('wrong password', call(null, 'POST', '/auth/login', { email: 'cashier.hd@autocare.vn', password: 'wrong-pass' }), 401);
await expectStatus('no token', call(null, 'GET', '/repair-orders'), 401);

console.log('\nUC27 – Assign Mechanic (RO 10 is NEW)');
await expectStatus('mechanic cannot assign', call(m1, 'POST', '/repair-orders/10/assign', { mechanicId: 8 }), 403);
await expectStatus('other-branch receptionist (BR48)', call(recHD, 'POST', '/repair-orders/10/assign', { mechanicId: 8 }), 403);
await expectStatus('mechanic of another branch', call(rec, 'POST', '/repair-orders/10/assign', { mechanicId: 13 }), 400);
await expectStatus('staff who is not a mechanic', call(rec, 'POST', '/repair-orders/10/assign', { mechanicId: 5 }), 400);
let r = await expectStatus('assign mechanic3', call(rec, 'POST', '/repair-orders/10/assign', { mechanicId: 8 }), 200);
check('order becomes ASSIGNED', r.data.status === 'ASSIGNED');
check('task stores mechanic', r.data.tasks.every((t) => t.mechanicId === 8));
await expectStatus('order already IN_PROGRESS cannot be reassigned', call(rec, 'POST', '/repair-orders/8/assign', { mechanicId: 7 }), 409);
r = await call(rec, 'GET', '/repair-orders/10/mechanics');
check('mechanic list = same branch only', r.data.length === 3 && r.data.every((x) => [6, 7, 8].includes(x.id)));

console.log('\nUC29 – Update Repair Progress (RO 9, task 16 assigned to mechanic1)');
await expectStatus('not the assigned mechanic (BR22)', call(m2, 'PATCH', '/repair-tasks/16/progress', { status: 'DOING', progressPercent: 10 }), 403);
await expectStatus('cannot jump TODO → DONE', call(m1, 'PATCH', '/repair-tasks/16/progress', { status: 'DONE', progressPercent: 100 }), 409);
r = await expectStatus('start work', call(m1, 'PATCH', '/repair-tasks/16/progress', { status: 'DOING', progressPercent: 20 }), 200);
check('order becomes IN_PROGRESS', r.data.status === 'IN_PROGRESS');
await expectStatus('progress cannot decrease', call(m1, 'PATCH', '/repair-tasks/16/progress', { status: 'DOING', progressPercent: 10 }), 400);
await expectStatus('100% must use DONE', call(m1, 'PATCH', '/repair-tasks/16/progress', { status: 'DOING', progressPercent: 100 }), 400);
await expectStatus('BLOCKED needs a reason', call(m1, 'PATCH', '/repair-tasks/16/progress', { status: 'BLOCKED', progressPercent: 30 }), 400);
r = await expectStatus('pause for parts (29.A1)', call(m1, 'PATCH', '/repair-tasks/16/progress', { status: 'BLOCKED', progressPercent: 30, note: 'Chờ lọc dầu' }), 200);
check('order becomes WAITING_PARTS', r.data.status === 'WAITING_PARTS');
const notes = await call(rec, 'GET', '/auth/notifications');
check('receptionist alerted', notes.data.some((n) => n.title === 'Hạng mục chờ phụ tùng'));
r = await expectStatus('resume', call(m1, 'PATCH', '/repair-tasks/16/progress', { status: 'DOING', progressPercent: 60, laborHours: 0.5 }), 200);
check('order back to IN_PROGRESS', r.data.status === 'IN_PROGRESS');

console.log('\nUC37 – Request Parts (RO 8, task 14 DOING, mechanic1)');
r = await call(m1, 'GET', '/repair-orders/8');
const parts = Object.fromEntries(r.data.parts.map((p) => [p.sku, p]));
await expectStatus('more than approved quantity', call(m1, 'POST', '/part-requests', { repairOrderId: 8, taskId: 14, items: [{ quotationItemId: parts['BAT-12V-45AH'].quotationItemId, quantity: 2 }] }), 400);
await expectStatus('item of another order', call(m1, 'POST', '/part-requests', { repairOrderId: 8, taskId: 14, items: [{ quotationItemId: 1, quantity: 1 }] }), 400);
await expectStatus('mechanic not assigned to task', call(m2, 'POST', '/part-requests', { repairOrderId: 8, taskId: 14, items: [{ quotationItemId: parts['FLT-CABIN'].quotationItemId, quantity: 1 }] }), 403);
r = await expectStatus('create request', call(m1, 'POST', '/part-requests', {
  repairOrderId: 8, taskId: 14, note: 'Thay lọc gió và nạp gas',
  items: [{ quotationItemId: parts['FLT-CABIN'].quotationItemId, quantity: 1 }, { quotationItemId: parts['AC-GAS-R134A'].quotationItemId, quantity: 1 }],
}), 201);
const newReq = r.data;
check('request is PENDING with 2 items', newReq.status === 'PENDING' && newReq.items.length === 2);
await expectStatus('cannot request the same part twice', call(m1, 'POST', '/part-requests', { repairOrderId: 8, taskId: 14, items: [{ quotationItemId: parts['FLT-CABIN'].quotationItemId, quantity: 1 }] }), 400);

console.log('\nUC38 – Issue Parts (receptionist branch 1)');
await expectStatus('other branch cannot issue (BR48)', call(recHD, 'POST', `/part-requests/${newReq.id}/issue`, {}), 403);
await expectStatus('mechanic cannot issue', call(m1, 'POST', `/part-requests/${newReq.id}/issue`, {}), 403);
const before = (await call(rec, 'GET', `/part-requests/${newReq.id}`)).data.items;
r = await expectStatus('issue all', call(rec, 'POST', `/part-requests/${newReq.id}/issue`, {}), 200);
check('request ISSUED', r.data.status === 'ISSUED');
check('on-hand and reserved decreased', r.data.items.every((it, i) => it.onHand === before[i].onHand - 1 && it.reservedQty === before[i].reservedQty - 1));
await expectStatus('cannot issue twice', call(rec, 'POST', `/part-requests/${newReq.id}/issue`, {}), 409);
r = await call(rec, 'GET', '/part-requests/6');
const oil = r.data.items.find((i) => i.sku === 'OIL-5W30-1L');
r = await expectStatus('partial issue (3 of 6 oil)', call(rec, 'POST', '/part-requests/6/issue', { items: [{ requestItemId: oil.id, quantity: 3 }] }), 200);
check('request PARTIALLY_ISSUED', r.data.status === 'PARTIALLY_ISSUED');
await expectStatus('more than remaining', call(rec, 'POST', '/part-requests/6/issue', { items: [{ requestItemId: oil.id, quantity: 4 }] }), 400);
r = await expectStatus('issue the rest', call(rec, 'POST', '/part-requests/6/issue', {}), 200);
check('request ISSUED', r.data.status === 'ISSUED');
r = await expectStatus('unreserved approved item (brake disc)', call(rec, 'POST', '/part-requests/7/issue', {}), 200);
check('issued from free stock', r.data.status === 'ISSUED');

console.log('\nUC32 – Complete Repair Order');
await expectStatus('unfinished tasks (BR24)', call(m1, 'POST', '/repair-orders/6/complete'), 409);
await expectStatus('receptionist cannot mark complete', call(rec, 'POST', '/repair-orders/5/complete'), 403);
await expectStatus('verify before completion', call(rec, 'POST', '/repair-orders/5/verify', {}), 409);
r = await expectStatus('mechanic completes RO 5', call(m1, 'POST', '/repair-orders/5/complete'), 200);
check('order COMPLETED', r.data.status === 'COMPLETED' && r.data.completedAt);
const cashierNotesBefore = (await call(cashier, 'GET', '/auth/notifications')).data.length;
r = await expectStatus('receptionist verifies', call(rec, 'POST', '/repair-orders/5/verify', { note: 'Đã chạy thử, xe hoạt động tốt' }), 200);
check('appointment WAITING_PAYMENT', r.data.appointmentStatus === 'WAITING_PAYMENT');
check('cashier notified', (await call(cashier, 'GET', '/auth/notifications')).data.length === cashierNotesBefore + 1);
await expectStatus('verify twice', call(rec, 'POST', '/repair-orders/5/verify', {}), 409);
// finish RO 8 without requesting the battery → its reservation must be released
await call(m1, 'PATCH', '/repair-tasks/14/progress', { status: 'DONE', progressPercent: 100 });
await call(m1, 'PATCH', '/repair-tasks/15/progress', { status: 'DOING', progressPercent: 50 });
await call(m1, 'PATCH', '/repair-tasks/15/progress', { status: 'DONE', progressPercent: 100 });
const batBefore = (await call(rec, 'GET', '/repair-orders/8')).data.parts.find((p) => p.sku === 'BAT-12V-45AH');
r = await expectStatus('complete RO 8', call(m1, 'POST', '/repair-orders/8/complete'), 200);
const batAfter = r.data.parts.find((p) => p.sku === 'BAT-12V-45AH');
check('unused reservation released', batBefore.reservedQty === 1 && batAfter.reservedQty === 0 && batAfter.available === batBefore.available + 1);

console.log(`\n${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);
