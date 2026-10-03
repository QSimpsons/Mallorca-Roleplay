(() => {
  const ARC_TOTAL = 2 * Math.PI * 48;
  const ARC_VISIBLE = ARC_TOTAL * 0.75;
  const ARC_HIDDEN = ARC_TOTAL - ARC_VISIBLE;
  const FUEL_CIRC = 2 * Math.PI * 17;

  const root = document.getElementById('speedo');
  const speedEl = document.getElementById('speed');
  const unitEl = document.getElementById('unit');
  const arcEl = document.getElementById('arc');
  const leftEl = document.getElementById('ind-left');
  const rightEl = document.getElementById('ind-right');
  const hazardEl = document.getElementById('ind-hazard');
  const engineEl = document.getElementById('ind-engine');
  const damageEl = document.getElementById('ind-damage');
  const handbrakeEl = document.getElementById('ind-handbrake');
  const lightsEl = document.getElementById('ind-lights');
  const fuelEl = document.getElementById('fuel');
  const fuelArcEl = document.getElementById('fuel-arc');
  const fuelPctEl = document.getElementById('fuel-pct');

  if (arcEl) {
    arcEl.style.strokeDasharray = String(ARC_TOTAL);
    arcEl.style.strokeDashoffset = String(ARC_TOTAL);
  }
  if (fuelArcEl) {
    fuelArcEl.style.strokeDasharray = String(FUEL_CIRC);
    fuelArcEl.style.strokeDashoffset = '0';
  }

  function setActive(node, on) {
    if (!node) return;
    node.classList.toggle('active', !!on);
  }

  function setStatus(node, status) {
    if (!node) return;
    node.classList.remove('green', 'yellow', 'red');
    node.classList.add(status || 'green');
  }

  function setFuel(percent, status) {
    const p = Math.max(0, Math.min(100, Number(percent) || 0));
    let st = status;
    if (!st) {
      if (p >= 40) st = 'green';
      else if (p >= 15) st = 'yellow';
      else st = 'red';
    }
    if (fuelPctEl) fuelPctEl.textContent = Math.round(p) + '%';
    if (fuelArcEl) fuelArcEl.style.strokeDashoffset = String(FUEL_CIRC * (1 - p / 100));
    if (fuelEl) {
      fuelEl.classList.remove('green', 'yellow', 'red');
      fuelEl.classList.add(st);
    }
  }

  function update(data) {
    data = data || {};
    const max = Number(data.maxSpeed) || 280;
    const speed = Math.max(0, Math.min(max, Number(data.speed) || 0));
    const ratio = speed / max;

    speedEl.textContent = String(Math.round(speed));
    unitEl.textContent = (data.unit || 'km/h').toUpperCase();

    if (arcEl) {
      arcEl.style.strokeDashoffset = String(ARC_HIDDEN + ARC_VISIBLE * (1 - ratio));
    }

    setActive(leftEl, data.left);
    setActive(rightEl, data.right);
    setActive(hazardEl, data.hazard);
    setActive(handbrakeEl, data.handbrake);
    setStatus(engineEl, data.engine);
    setStatus(damageEl, data.damage);
    setFuel(data.fuel != null ? data.fuel : 100, data.fuelState);

    if (lightsEl) {
      lightsEl.classList.toggle('on', !!data.lights);
    }

    root.classList.add('visible');
    root.setAttribute('aria-hidden', 'false');
  }

  function hide() {
    root.classList.remove('visible');
    root.setAttribute('aria-hidden', 'true');
  }

  window.addEventListener('message', function (event) {
    const msg = event.data || {};
    if (msg.action === 'update') update(msg.data || {});
    if (msg.action === 'hide') hide();
  });
})();
