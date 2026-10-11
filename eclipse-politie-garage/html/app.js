(() => {
  const app = document.getElementById('app');
  const categoriesEl = document.getElementById('categories');
  const gridEl = document.getElementById('grid');
  const emptyEl = document.getElementById('empty');
  const searchEl = document.getElementById('search');
  const catTitle = document.getElementById('cat-title');
  const catCount = document.getElementById('cat-count');
  const locationEl = document.getElementById('location');
  const gradeLabel = document.getElementById('grade-label');
  const brandTitle = document.getElementById('brand-title');
  const closeBtn = document.getElementById('btn-close');

  const FAV_KEY = 'eclipse_politie_garage_favorites';

  let state = {
    open: false,
    garageId: null,
    categories: [],
    vehicles: [],
    activeCategory: null,
    texts: {},
    favorites: loadFavorites(),
    query: '',
  };

  const ICONS = {
    star: '<svg viewBox="0 0 24 24" width="18" height="18"><path fill="currentColor" d="M12 3.5l2.6 5.3 5.9.9-4.3 4.2 1 5.8L12 16.9 6.8 19.7l1-5.8L3.5 9.7l5.9-.9L12 3.5z"/></svg>',
    radio: '<svg viewBox="0 0 24 24" width="18" height="18"><path fill="currentColor" d="M4 7h16a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V9a2 2 0 0 1 2-2zm1 3v7h14v-7H5zm7 1a2.5 2.5 0 1 1 0 5 2.5 2.5 0 0 1 0-5zM7 4l9.5 3H18L7 3.2V4z"/></svg>',
    car: '<svg viewBox="0 0 24 24" width="18" height="18"><path fill="currentColor" d="M5 11l1.5-4.5A2 2 0 0 1 8.4 5h7.2a2 2 0 0 1 1.9 1.5L19 11h1a1 1 0 0 1 1 1v5h-2a2 2 0 1 1-4 0H9a2 2 0 1 1-4 0H3v-5a1 1 0 0 1 1-1h1zm2.2-1h9.6l-1-3H8.2l-1 3z"/></svg>',
    ghost: '<svg viewBox="0 0 24 24" width="18" height="18"><path fill="currentColor" d="M12 3a7 7 0 0 1 7 7v9.2l-2.2-1.5-2.3 1.5-2.5-1.6-2.5 1.6-2.3-1.5L5 19.2V10a7 7 0 0 1 7-7zm-2.5 8a1.3 1.3 0 1 0 0-2.6 1.3 1.3 0 0 0 0 2.6zm5 0a1.3 1.3 0 1 0 0-2.6 1.3 1.3 0 0 0 0 2.6z"/></svg>',
    bike: '<svg viewBox="0 0 24 24" width="18" height="18"><path fill="currentColor" d="M5.5 17a3.5 3.5 0 1 1 0-7 3.5 3.5 0 0 1 0 7zm13 0a3.5 3.5 0 1 1 0-7 3.5 3.5 0 0 1 0 7zM9 11l2-5h3l2 3h3v2h-4l-1.5-2.2L12.2 12H9z"/></svg>',
    air: '<svg viewBox="0 0 24 24" width="18" height="18"><path fill="currentColor" d="M12 2 4 8v2l6-2v4l-4 2v2l4-1 2 5h2l2-5 4 1v-2l-4-2V8l6 2V8l-8-6z"/></svg>',
    shield: '<svg viewBox="0 0 24 24" width="18" height="18"><path fill="currentColor" d="M12 2 4 5v6c0 5 3.4 9.4 8 11 4.6-1.6 8-6 8-11V5l-8-3zm0 4.2 5 1.9v4.4c0 3.4-2.2 6.5-5 7.8-2.8-1.3-5-4.4-5-7.8V8.1l5-1.9z"/></svg>',
    armor: '<svg viewBox="0 0 24 24" width="18" height="18"><path fill="currentColor" d="M12 2 3 6v6c0 5.5 3.8 10.7 9 12 5.2-1.3 9-6.5 9-12V6l-9-4z"/></svg>',
    heart: '<svg viewBox="0 0 24 24" width="18" height="18"><path fill="currentColor" d="M12 21s-7-4.6-9.5-9A5.5 5.5 0 0 1 12 6a5.5 5.5 0 0 1 9.5 6C19 16.4 12 21 12 21z"/></svg>',
  };

  function loadFavorites() {
    try {
      const raw = localStorage.getItem(FAV_KEY);
      const arr = raw ? JSON.parse(raw) : [];
      return new Set(Array.isArray(arr) ? arr : []);
    } catch (_) {
      return new Set();
    }
  }

  function saveFavorites() {
    localStorage.setItem(FAV_KEY, JSON.stringify([...state.favorites]));
  }

  function nui(name, data) {
    const res = typeof GetParentResourceName === 'function'
      ? GetParentResourceName()
      : 'eclipse-politie-garage';
    return fetch(`https://${res}/${name}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(data || {}),
    }).catch(() => null);
  }

  function open(data) {
    state.open = true;
    state.garageId = data.garageId;
    state.categories = data.categories || [];
    state.vehicles = data.vehicles || [];
    state.texts = data.texts || {};
    state.query = '';
    searchEl.value = '';
    searchEl.placeholder = state.texts.search || 'Zoek voertuig…';
    brandTitle.textContent = data.title || 'POLITIE GARAGE';
    locationEl.textContent = data.location || 'Garage';
    gradeLabel.textContent = `Rang ${data.grade ?? '—'}`;

    const first = state.categories.find((c) => c.special !== 'favorites') || state.categories[0];
    state.activeCategory = (first && first.id) || null;

    app.classList.add('visible');
    app.setAttribute('aria-hidden', 'false');
    renderCategories();
    renderGrid();
  }

  function close() {
    state.open = false;
    app.classList.remove('visible');
    app.setAttribute('aria-hidden', 'true');
    nui('close');
  }

  function activeCategoryMeta() {
    return state.categories.find((c) => c.id === state.activeCategory) || null;
  }

  function filteredVehicles() {
    const q = state.query.trim().toLowerCase();
    const cat = activeCategoryMeta();
    return state.vehicles.filter((v) => {
      let inCat = true;
      if (cat && cat.special === 'favorites') {
        inCat = state.favorites.has(v.id);
      } else if (state.activeCategory) {
        inCat = v.category === state.activeCategory;
      }
      if (!inCat) return false;
      if (!q) return true;
      return (
        (v.label || '').toLowerCase().includes(q) ||
        (v.model || '').toLowerCase().includes(q) ||
        (v.badge || '').toLowerCase().includes(q)
      );
    });
  }

  function renderCategories() {
    categoriesEl.innerHTML = '';
    state.categories.forEach((cat) => {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'cat-btn' + (cat.id === state.activeCategory ? ' active' : '');
      btn.innerHTML = `<span class="cat-icon">${ICONS[cat.icon] || ICONS.car}</span><span>${escapeHtml(cat.label)}</span>`;
      btn.addEventListener('click', () => {
        state.activeCategory = cat.id;
        renderCategories();
        renderGrid();
      });
      categoriesEl.appendChild(btn);
    });
  }

  function renderGrid() {
    const list = filteredVehicles();
    const cat = activeCategoryMeta();
    catTitle.textContent = cat ? cat.label : 'Voertuigen';
    catCount.textContent = `${list.length} voertuig${list.length === 1 ? '' : 'en'}`;

    gridEl.innerHTML = '';
    if (!list.length) {
      emptyEl.textContent = cat && cat.special === 'favorites'
        ? (state.texts.favoritesEmpty || 'Nog geen favorieten.')
        : (state.texts.empty || 'Geen voertuigen in deze categorie.');
      emptyEl.classList.remove('hidden');
      return;
    }
    emptyEl.classList.add('hidden');

    list.forEach((v, index) => {
      const card = document.createElement('article');
      card.className = 'card';
      card.style.animationDelay = `${Math.min(index, 12) * 0.035}s`;
      card.setAttribute('role', 'listitem');

      const isFav = state.favorites.has(v.id);
      const stats = v.stats || {};
      const t = state.texts;

      card.innerHTML = `
        <div class="card-media">
          ${v.badge ? `<span class="badge">${escapeHtml(v.badge)}</span>` : ''}
          <button type="button" class="fav-btn ${isFav ? 'on' : ''}" data-fav="${escapeAttr(v.id)}" aria-label="Favoriet">
            <svg viewBox="0 0 24 24" width="16" height="16"><path fill="currentColor" d="M12 3.5l2.6 5.3 5.9.9-4.3 4.2 1 5.8L12 16.9 6.8 19.7l1-5.8L3.5 9.7l5.9-.9L12 3.5z"/></svg>
          </button>
          <img src="${escapeAttr(v.image || '')}" alt="${escapeAttr(v.label)}" loading="lazy" onerror="this.style.opacity='0.25'" />
        </div>
        <div class="card-body">
          <h3>${escapeHtml(v.label)}</h3>
          <div class="stats">
            ${statRow(t.speed || 'Snelheid', stats.speed)}
            ${statRow(t.accel || 'Acceleratie', stats.accel)}
            ${statRow(t.brake || 'Remmen', stats.brake)}
            ${statRow(t.handling || 'Handling', stats.handling)}
          </div>
          <button type="button" class="spawn-btn" data-spawn="${escapeAttr(v.id)}">${escapeHtml(t.spawn || 'SPAWN VOERTUIG')}</button>
        </div>
      `;

      gridEl.appendChild(card);

      requestAnimationFrame(() => {
        card.querySelectorAll('.bar > i').forEach((el) => {
          el.style.width = `${el.dataset.value || 0}%`;
        });
      });
    });
  }

  function statRow(label, value) {
    const v = Math.max(0, Math.min(100, Number(value) || 0));
    return `<div class="stat"><span>${escapeHtml(label)}</span><div class="bar"><i data-value="${v}"></i></div></div>`;
  }

  function escapeHtml(str) {
    return String(str ?? '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  function escapeAttr(str) {
    return escapeHtml(str).replace(/'/g, '&#39;');
  }

  gridEl.addEventListener('click', (e) => {
    const fav = e.target.closest('[data-fav]');
    if (fav) {
      const id = fav.getAttribute('data-fav');
      if (state.favorites.has(id)) state.favorites.delete(id);
      else state.favorites.add(id);
      saveFavorites();
      renderGrid();
      return;
    }
    const spawn = e.target.closest('[data-spawn]');
    if (spawn) {
      const vehicleId = spawn.getAttribute('data-spawn');
      nui('spawn', { vehicleId, garageId: state.garageId });
    }
  });

  searchEl.addEventListener('input', () => {
    state.query = searchEl.value || '';
    renderGrid();
  });

  closeBtn.addEventListener('click', close);

  window.addEventListener('keydown', (e) => {
    if (!state.open) return;
    if (e.key === 'Escape') close();
  });

  window.addEventListener('message', (event) => {
    const msg = event.data || {};
    if (msg.action === 'open') open(msg.data || {});
    if (msg.action === 'close') {
      state.open = false;
      app.classList.remove('visible');
      app.setAttribute('aria-hidden', 'true');
    }
  });

  // Browser preview helper
  window.__POLITIE_GARAGE_DEMO__ = function (payload) {
    document.body.classList.add('demo-mode');
    open(payload);
  };

  nui('ready');
})();
