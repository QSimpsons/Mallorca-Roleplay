const assert = require('assert');
const { formatTime, fromMinutes, toMinutes } = require('../html/logic.js');

assert.strictEqual(formatTime(14, 0, false), '2:00 PM');
assert.strictEqual(formatTime(0, 0, false), '12:00 AM');
assert.strictEqual(formatTime(12, 0, false), '12:00 PM');
assert.strictEqual(formatTime(23, 59, false), '11:59 PM');
assert.strictEqual(formatTime(14, 0, true), '14:00');
assert.strictEqual(formatTime(0, 5, true), '00:05');
assert.strictEqual(formatTime(9, 5, true), '09:05');

assert.strictEqual(toMinutes(14, 0), 840);
assert.deepStrictEqual(fromMinutes(840), { hour: 14, minute: 0 });
assert.deepStrictEqual(fromMinutes(0), { hour: 0, minute: 0 });
assert.deepStrictEqual(fromMinutes(1439), { hour: 23, minute: 59 });
assert.deepStrictEqual(fromMinutes(-20), { hour: 0, minute: 0 });
assert.deepStrictEqual(fromMinutes(5000), { hour: 23, minute: 59 });

console.log('logic.test.js ok');
