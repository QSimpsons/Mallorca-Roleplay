(() => {
  const CIRC = 2 * Math.PI * 16;

  const el = {
    hud: document.getElementById('hud'),
    hungerFill: document.getElementById('hunger-fill'),
    hungerValue: document.getElementById('hunger-value'),
    thirstFill: document.getElementById('thirst-fill'),
    thirstValue: document.getElementById('thirst-value'),
    playerId: document.getElementById('player-id'),
    job1: document.getElementById('job1'),
    job2: document.getElementById('job2'),
    healthArc: document.getElementById('health-arc'),
    armorArc: document.getElementById('armor-arc'),
    staminaArc: document.getElementById('stamina-arc'),
    voiceArc: document.getElementById('voice-arc'),
    voiceWrap: document.getElementById('voice-wrap'),
    money: document.getElementById('money'),
    cash: document.getElementById('cash'),
    bank: document.getElementById('bank'),
    location: document.getElementById('location'),
    street: document.getElementById('street'),
    zone: document.getElementById('zone'),
  };

  function clamp(n, min = 0, max = 100) {
    n = Number(n);
    if (Number.isNaN(n)) return min;
    return Math.max(min, Math.min(max, n));
  }

  function setBar(fill, valueEl, pct, needEl) {
    const v = clamp(pct);
    fill.style.width = `${v}%`;
    valueEl.textContent = `${Math.round(v)}%`;
    if (needEl) needEl.classList.toggle('is-low', v <= 20);
  }

  function setArc(arc, pct) {
    const v = clamp(pct);
    const offset = CIRC - (CIRC * v) / 100;
    arc.style.strokeDasharray = `${CIRC}`;
    arc.style.strokeDashoffset = `${offset}`;
  }

  function formatMoney(amount) {
    const n = Math.floor(Number(amount) || 0);
    return `€${n.toLocaleString('nl-NL')}`;
  }

  function show(visible) {
    el.hud.classList.toggle('is-visible', !!visible);
    el.hud.setAttribute('aria-hidden', visible ? 'false' : 'true');
  }

  function update(data = {}) {
    if (typeof data.visible === 'boolean') show(data.visible);

    if (data.hunger != null) {
      setBar(el.hungerFill, el.hungerValue, data.hunger, el.hungerFill.closest('.need'));
    }
    if (data.thirst != null) {
      setBar(el.thirstFill, el.thirstValue, data.thirst, el.thirstFill.closest('.need'));
    }

    if (data.id != null) el.playerId.textContent = String(data.id);
    if (data.job1 != null) el.job1.textContent = data.job1 || 'Werkloos';
    if (data.job2 != null) el.job2.textContent = data.job2 || 'Geen';

    if (data.health != null) {
      const h = clamp(data.health);
      setArc(el.healthArc, h);
      el.healthArc.closest('.vital')?.classList.toggle('is-low', h <= 25);
    }
    if (data.armor != null) setArc(el.armorArc, data.armor);
    if (data.stamina != null) setArc(el.staminaArc, data.stamina);

    if (typeof data.showVoice === 'boolean') {
      el.voiceWrap.classList.toggle('is-hidden', !data.showVoice);
    }
    if (data.voice != null) setArc(el.voiceArc, data.voice);
    if (typeof data.talking === 'boolean') {
      el.voiceWrap.classList.toggle('is-talking', data.talking);
    }

    if (typeof data.showMoney === 'boolean') {
      el.money.classList.toggle('is-visible', data.showMoney);
      el.money.setAttribute('aria-hidden', data.showMoney ? 'false' : 'true');
    }
    if (data.cash != null) el.cash.textContent = formatMoney(data.cash);
    if (data.bank != null) el.bank.textContent = formatMoney(data.bank);

    if (typeof data.showLocation === 'boolean') {
      el.location.classList.toggle('is-visible', data.showLocation);
      el.location.setAttribute('aria-hidden', data.showLocation ? 'false' : 'true');
    }
    if (data.street != null) el.street.textContent = data.street || '—';
    if (data.zone != null) el.zone.textContent = data.zone || '—';
  }

  window.addEventListener('message', (event) => {
    const msg = event.data;
    if (!msg || typeof msg !== 'object') return;

    if (msg.action === 'show') {
      show(!!msg.visible);
      return;
    }
    if (msg.action === 'update' || msg.action === 'hud') {
      update(msg.data || msg);
      return;
    }
    if (msg.action === 'set') {
      update(msg);
    }
  });

  // Browser preview helper
  if (!window.invokeNative) {
    show(true);
    update({
      hunger: 78,
      thirst: 62,
      id: 42,
      job1: 'Politie',
      job2: 'Monteur',
      health: 92,
      armor: 40,
      stamina: 70,
      voice: 66,
      talking: false,
      showVoice: true,
      showMoney: true,
      cash: 2450,
      bank: 12800,
      showLocation: true,
      street: 'Power Street',
      zone: 'Pillbox Hill',
    });
  }

  // Init arcs
  [el.healthArc, el.armorArc, el.staminaArc, el.voiceArc].forEach((arc) => {
    arc.style.strokeDasharray = `${CIRC}`;
    arc.style.strokeDashoffset = '0';
  });
})();
