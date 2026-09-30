(() => {
  const el = {
    hud: document.getElementById('hud'),
    playerId: document.getElementById('player-id'),
    job1: document.getElementById('job1'),
    job2: document.getElementById('job2'),
    hungerBox: document.getElementById('hunger-box'),
    thirstBox: document.getElementById('thirst-box'),
    hungerFill: document.getElementById('hunger-fill'),
    thirstFill: document.getElementById('thirst-fill'),
    money: document.getElementById('money'),
    cash: document.getElementById('cash'),
    bank: document.getElementById('bank'),
    black: document.getElementById('black'),
    location: document.getElementById('location'),
    street: document.getElementById('street'),
    zone: document.getElementById('zone'),
    voiceWrap: document.getElementById('voice-wrap'),
  };

  function clamp(n, min = 0, max = 100) {
    n = Number(n);
    if (Number.isNaN(n)) return min;
    return Math.max(min, Math.min(max, n));
  }

  function formatMoney(amount) {
    const n = Math.floor(Number(amount) || 0);
    return `€${n.toLocaleString('nl-NL')}`;
  }

  function setNeed(box, fill, pct) {
    const v = clamp(pct);
    fill.style.transform = `scaleY(${v / 100})`;
    box.classList.toggle('is-low', v <= 20);
    box.title = `${box.dataset.label || box.title.split(':')[0]}: ${Math.round(v)}%`;
  }

  function show(visible) {
    el.hud.classList.toggle('is-visible', !!visible);
    el.hud.setAttribute('aria-hidden', visible ? 'false' : 'true');
  }

  function update(data = {}) {
    if (typeof data.visible === 'boolean') show(data.visible);

    if (data.id != null) el.playerId.textContent = String(data.id);
    if (data.job1 != null) el.job1.textContent = data.job1 || 'Werkloos';
    if (data.job2 != null) el.job2.textContent = data.job2 || 'Geen';

    if (data.hunger != null) setNeed(el.hungerBox, el.hungerFill, data.hunger);
    if (data.thirst != null) setNeed(el.thirstBox, el.thirstFill, data.thirst);

    if (typeof data.showMoney === 'boolean') {
      el.money.classList.toggle('is-hidden', !data.showMoney);
    }
    if (data.cash != null) el.cash.textContent = formatMoney(data.cash);
    if (data.bank != null) el.bank.textContent = formatMoney(data.bank);
    if (data.black != null) {
      el.black.textContent = formatMoney(data.black);
      el.black.classList.toggle('is-hot', Number(data.black) > 0);
    }

    if (typeof data.showLocation === 'boolean') {
      el.location.classList.toggle('is-visible', data.showLocation);
      el.location.setAttribute('aria-hidden', data.showLocation ? 'false' : 'true');
    }
    if (data.street != null) el.street.textContent = data.street || '—';
    if (data.zone != null) el.zone.textContent = data.zone || '—';

    if (typeof data.showVoice === 'boolean') {
      el.voiceWrap.classList.toggle('is-visible', data.showVoice);
      el.voiceWrap.setAttribute('aria-hidden', data.showVoice ? 'false' : 'true');
    }
    if (typeof data.talking === 'boolean') {
      el.voiceWrap.classList.toggle('is-talking', data.talking);
    }
  }

  window.addEventListener('message', (event) => {
    const msg = event.data;
    if (!msg || typeof msg !== 'object') return;
    if (msg.action === 'show') {
      show(!!msg.visible);
      return;
    }
    if (msg.action === 'update' || msg.action === 'hud' || msg.action === 'set') {
      update(msg.data || msg);
    }
  });

  // Browser preview defaults
  if (!window.invokeNative) {
    show(true);
    update({
      id: 42,
      job1: 'Politie | Recherche',
      job2: 'Staff | Beheer',
      hunger: 82,
      thirst: 64,
      showMoney: true,
      cash: 1000,
      bank: 1000,
      black: 0,
      showLocation: true,
      street: 'Power Street',
      zone: 'Pillbox Hill',
      showVoice: true,
      talking: false,
    });
  }
})();
