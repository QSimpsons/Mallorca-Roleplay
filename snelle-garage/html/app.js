(function () {
  const isNui = typeof GetParentResourceName === 'function';
  const resName = isNui ? GetParentResourceName() : 'snelle-garage';
  const app = document.getElementById('app');
  const listEl = document.getElementById('list');
  const chipsEl = document.getElementById('chips');
  const statsEl = document.getElementById('stats');
  const walletEl = document.getElementById('wallet');
  const searchEl = document.getElementById('search');
  const demoEl = document.getElementById('demo');
  const toasts = document.getElementById('toasts');

  const state = {
    mode: 'garage',
    title: 'Garage',
    subtitle: '',
    vehicles: [],
    cash: 0,
    bank: 0,
    filter: 'all',
    query: '',
    busy: false
  };

  const filters = [
    { id: 'all', label: 'Alles' },
    { id: 'garage', label: 'Garage' },
    { id: 'out', label: 'Buiten' },
    { id: 'impound', label: 'Impound' }
  ];

  function el(tag, className, text) {
    const node = document.createElement(tag);
    if (className) node.className = className;
    if (text != null) node.textContent = text;
    return node;
  }

  function euro(amount) {
    const value = Math.floor(Number(amount) || 0);
    return '€' + value.toLocaleString('nl-NL');
  }

  function toast(message) {
    const node = el('div', 'toast', message);
    toasts.appendChild(node);
    setTimeout(function () { node.remove(); }, 2800);
  }

  function post(name, body) {
    if (!isNui) {
      handleDemo(name, body || {});
      return;
    }
    fetch('https://' + resName + '/' + name, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(body || {})
    }).catch(function () {});
  }

  function fromThousand(value) {
    if (value == null || value === '') return null;
    const n = Number(value);
    if (Number.isNaN(n)) return null;
    return Math.max(0, Math.min(100, Math.round(n / 10)));
  }

  function fromFuel(value) {
    if (value == null || value === '') return null;
    const n = Number(value);
    if (Number.isNaN(n)) return null;
    if (n > 100) return Math.max(0, Math.min(100, Math.round(n / 10)));
    return Math.max(0, Math.min(100, Math.round(n)));
  }

  function statusLabel(status) {
    if (status === 'garage') return 'In garage';
    if (status === 'out') return 'Buiten';
    if (status === 'impound') return 'Impound';
    return status;
  }

  function actionFor(vehicle) {
    const mode = state.mode;
    if (mode === 'impound' && (vehicle.state === 'impound' || vehicle.state === 'out')) {
      const price = Number(vehicle.price) || 0;
      return {
        label: price > 0 ? 'Betaal ' + euro(price) : 'Ophalen',
        enabled: !state.busy
      };
    }
    if ((mode === 'garage' || mode === 'call') && vehicle.state === 'garage' && vehicle.here !== false) {
      const price = mode === 'call' ? (Number(vehicle.price) || 0) : 0;
      return {
        label: price > 0 ? 'Oproepen · ' + euro(price) : 'Oproepen',
        enabled: !state.busy
      };
    }
    if (vehicle.state === 'impound') return { label: 'Staat in de impound', enabled: false };
    if (vehicle.state === 'out') return { label: 'Staat buiten', enabled: false };
    if (vehicle.here === false) return { label: 'Andere garage', enabled: false };
    return { label: 'Niet beschikbaar', enabled: false };
  }

  function visibleVehicles() {
    const q = state.query.trim().toLowerCase();
    return state.vehicles.filter(function (vehicle) {
      if (state.filter !== 'all' && vehicle.state !== state.filter) return false;
      if (!q) return true;
      const name = (vehicle.label || '').toLowerCase();
      const plate = (vehicle.plate || '').toLowerCase();
      return name.indexOf(q) !== -1 || plate.indexOf(q) !== -1;
    });
  }

  function renderChips() {
    chipsEl.innerHTML = '';
    filters.forEach(function (filter) {
      const button = el('button', 'chip' + (state.filter === filter.id ? ' active' : ''), filter.label);
      button.type = 'button';
      button.addEventListener('click', function () {
        state.filter = filter.id;
        render();
      });
      chipsEl.appendChild(button);
    });
  }

  function renderStats() {
    const counts = { garage: 0, out: 0, impound: 0 };
    (state.vehicles || []).forEach(function (vehicle) {
      if (counts[vehicle.state] != null) counts[vehicle.state] += 1;
    });
    statsEl.innerHTML = '';
    [
      ['In garage', counts.garage],
      ['Buiten', counts.out],
      ['Impound', counts.impound]
    ].forEach(function (item) {
      const box = el('div', 'stat');
      box.appendChild(el('span', null, item[0]));
      box.appendChild(el('strong', null, String(item[1])));
      statsEl.appendChild(box);
    });
  }

  function renderWallet() {
    walletEl.innerHTML = '';
    [
      ['Contant', state.cash],
      ['Bank', state.bank]
    ].forEach(function (item) {
      const box = el('span');
      box.appendChild(document.createTextNode(item[0] + ' '));
      box.appendChild(el('strong', null, euro(item[1])));
      walletEl.appendChild(box);
    });
  }

  function meter(label, value) {
    if (value == null) return null;
    const wrap = el('div', 'meter');
    const caption = el('span');
    caption.appendChild(el('b', null, label));
    caption.appendChild(el('span', null, value + '%'));
    const bar = el('div', 'bar');
    const fill = el('i');
    fill.style.width = value + '%';
    bar.appendChild(fill);
    wrap.appendChild(caption);
    wrap.appendChild(bar);
    return wrap;
  }

  function renderList() {
    listEl.innerHTML = '';
    if (!state.vehicles) {
      listEl.appendChild(el('div', 'loading', 'Voertuigen laden...'));
      return;
    }
    const vehicles = visibleVehicles();
    if (vehicles.length === 0) {
      const empty = state.vehicles.length === 0
        ? 'Je hebt hier geen voertuigen.'
        : 'Geen voertuigen voor deze zoekopdracht.';
      listEl.appendChild(el('div', 'empty', empty));
      return;
    }
    vehicles.forEach(function (vehicle) {
      const card = el('article', 'card');
      const head = el('div', 'card-head');
      const title = el('div');
      title.appendChild(el('h2', null, vehicle.label || 'Voertuig'));
      const plate = el('span', 'plate');
      plate.appendChild(el('i', null, 'NL'));
      plate.appendChild(el('b', null, vehicle.plate || '—'));
      title.appendChild(plate);
      const action = actionFor(vehicle);
      const button = el('button', 'action', action.label);
      button.type = 'button';
      button.disabled = !action.enabled;
      button.addEventListener('click', function () {
        if (button.disabled) return;
        state.busy = true;
        render();
        post('take', { plate: vehicle.plate });
      });
      const actions = el('div', 'card-actions');
      actions.appendChild(el('span', 'badge ' + (vehicle.state || ''), statusLabel(vehicle.state)));
      actions.appendChild(button);
      head.appendChild(title);
      head.appendChild(actions);
      card.appendChild(head);

      const reason = el('p', 'reason', vehicle.reason || (vehicle.state === 'garage' ? 'Klaar om op te roepen' : ''));
      card.appendChild(reason);

      const meters = el('div', 'meters');
      const engine = meter('Motor', fromThousand(vehicle.engine));
      const body = meter('Carrosserie', fromThousand(vehicle.body));
      const fuel = meter('Brandstof', fromFuel(vehicle.fuel));
      if (engine) meters.appendChild(engine);
      if (body) meters.appendChild(body);
      if (fuel) meters.appendChild(fuel);
      card.appendChild(meters);

      listEl.appendChild(card);
    });
  }

  function render() {
    document.getElementById('location').textContent = state.title || 'Garage';
    document.getElementById('title').textContent = state.mode === 'impound'
      ? 'Impound'
      : (state.mode === 'call' ? 'Oproepen' : 'Garage');
    document.getElementById('subtitle').textContent = state.subtitle || '';
    document.getElementById('mode-label').textContent = state.mode === 'call'
      ? 'Toets of /oproep'
      : (state.mode === 'impound' ? 'Betaal en haal op' : 'E bij de garage');
    renderWallet();
    renderChips();
    renderStats();
    renderList();
  }

  function show() {
    app.classList.add('visible');
    app.setAttribute('aria-hidden', 'false');
  }

  function hide() {
    app.classList.remove('visible');
    app.setAttribute('aria-hidden', 'true');
    state.busy = false;
  }

  function open(data) {
    state.mode = data.mode || 'garage';
    state.title = data.title || 'Garage';
    state.subtitle = data.subtitle || '';
    state.vehicles = data.vehicles || [];
    state.cash = data.cash || 0;
    state.bank = data.bank || 0;
    state.busy = false;
    state.filter = 'all';
    state.query = '';
    searchEl.value = '';
    show();
    render();
  }

  function loading(data) {
    state.mode = (data && data.mode) || state.mode;
    state.title = (data && data.title) || state.title;
    state.subtitle = (data && data.subtitle) || 'Voertuigen laden...';
    state.vehicles = null;
    show();
    render();
  }

  window.addEventListener('message', function (event) {
    const data = event.data || {};
    if (data.action === 'open') open(data);
    if (data.action === 'loading') loading(data);
    if (data.action === 'close') hide();
    if (data.action === 'idle') {
      state.busy = false;
      render();
    }
  });

  document.getElementById('close').addEventListener('click', function () { post('close'); });
  document.getElementById('refresh').addEventListener('click', function () { post('refresh'); });
  searchEl.addEventListener('input', function () {
    state.query = searchEl.value;
    renderList();
  });
  document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape') post('close');
  });

  function demoVehicles(mode) {
    const all = [
      { plate: 'SNL 104', label: 'Sultan RS', state: 'garage', here: true, price: 0, engine: 940, body: 880, fuel: 72, reason: 'Klaar om op te roepen' },
      { plate: 'GX 4421', label: 'Bison', state: 'garage', here: true, price: 0, engine: 1000, body: 760, fuel: 41, reason: 'Klaar om op te roepen' },
      { plate: 'ML 9082', label: 'Dubsta', state: 'out', here: true, price: 2000, engine: 420, body: 510, fuel: 18, reason: 'Staat buiten of is vermist' },
      { plate: 'PK 2201', label: 'Baller', state: 'impound', here: true, price: 1500, engine: 800, body: 640, fuel: 55, reason: 'Getakeld · foutparkeren' }
    ];
    if (mode === 'impound') {
      return all.filter(function (vehicle) { return vehicle.state === 'impound' || vehicle.state === 'out'; });
    }
    if (mode === 'call') {
      return all.map(function (vehicle) {
        const copy = Object.assign({}, vehicle);
        if (copy.state === 'garage') copy.price = 0;
        return copy;
      });
    }
    return all;
  }

  function demoPayload(mode) {
    const titles = { garage: 'Garage Legion Square', impound: 'Impound Davis', call: 'Voertuig oproepen' };
    const subtitles = {
      garage: 'Kies een voertuig om op te roepen',
      impound: 'Betaal om een voertuig uit de impound te halen',
      call: 'Het voertuig wordt bij je in de buurt gezet'
    };
    return {
      mode: mode,
      title: titles[mode],
      subtitle: subtitles[mode],
      vehicles: demoVehicles(mode),
      cash: 4250,
      bank: 18600
    };
  }

  function handleDemo(name, body) {
    if (name === 'close') {
      hide();
      return;
    }
    if (name === 'refresh') {
      open(demoPayload(state.mode));
      toast('Lijst vernieuwd');
      return;
    }
    if (name === 'take') {
      const vehicle = state.vehicles.find(function (item) { return item.plate === body.plate; });
      if (!vehicle) return;
      if (state.mode === 'impound') {
        const price = Number(vehicle.price) || 0;
        if (state.cash >= price) state.cash -= price;
        else state.bank -= price;
        toast(vehicle.label + ' opgehaald uit de impound');
        state.vehicles = state.vehicles.filter(function (item) { return item.plate !== vehicle.plate; });
      } else {
        vehicle.state = 'out';
        vehicle.reason = 'Staat buiten of is vermist';
        vehicle.price = 2000;
        toast(vehicle.label + ' staat voor je klaar');
      }
      state.busy = false;
      render();
    }
  }

  const params = new URLSearchParams(window.location.search);
  if (!isNui && (params.get('auto') === '1' || params.get('demo') === '1')) {
    document.body.classList.add('demo-mode');
    demoEl.classList.remove('hidden');
    open(demoPayload('garage'));
    document.getElementById('demo-garage').addEventListener('click', function () { open(demoPayload('garage')); });
    document.getElementById('demo-impound').addEventListener('click', function () { open(demoPayload('impound')); });
    document.getElementById('demo-call').addEventListener('click', function () { open(demoPayload('call')); });
    document.getElementById('demo-close').addEventListener('click', function () { hide(); });
  }
})();
