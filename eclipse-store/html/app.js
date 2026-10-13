(() => {
  const diamond =
    '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 2.2L21.8 10 12 22 2.2 10 12 2.2z"/></svg>';

  const el = {
    root: document.getElementById('store-root'),
    body: document.body,
    topbar: document.getElementById('topbar'),
    brandName: document.getElementById('brand-name'),
    brandMark: document.getElementById('brand-mark'),
    catList: document.getElementById('cat-list'),
    app: document.getElementById('app'),
    cartCount: document.getElementById('cart-count'),
    demoBanner: document.getElementById('demo-banner'),
    footerLeft: document.getElementById('footer-left'),
    webstoreLink: document.getElementById('webstore-link'),
    toastHost: document.getElementById('toast-host'),
    closeBtn: document.getElementById('close-btn'),
  };

  const state = {
    open: false,
    loading: false,
    demo: false,
    store: null,
    ui: null,
    categories: [],
    activeCategoryId: null,
    view: 'shop', // shop | package | basket
    packageId: null,
    basket: { packages: [], total_price: 0, currency: 'EUR', authorized: false },
  };

  function resourceName() {
    try {
      if (typeof GetParentResourceName === 'function') {
        return GetParentResourceName();
      }
    } catch (_) {}
    return 'eclipse-store';
  }

  function nui(event, data = {}) {
    return fetch(`https://${resourceName()}/${event}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(data),
    }).catch(() => null);
  }

  function money(amount, currency = 'EUR') {
    const n = Number(amount) || 0;
    try {
      return new Intl.NumberFormat('nl-NL', {
        style: 'currency',
        currency: currency || 'EUR',
      }).format(n);
    } catch (_) {
      return `€${n.toFixed(2)}`;
    }
  }

  function stripHtml(html) {
    if (!html) return '';
    const d = document.createElement('div');
    d.innerHTML = String(html);
    return (d.textContent || d.innerText || '').trim();
  }

  function toast(message, type = 'info') {
    if (!message) return;
    const node = document.createElement('div');
    node.className = `toast${type === 'error' ? ' error' : ''}`;
    node.textContent = message;
    el.toastHost.appendChild(node);
    setTimeout(() => node.remove(), 4200);
  }

  function openExternal(url) {
    if (!url) return;
    try {
      if (typeof window.invokeNative === 'function') {
        window.invokeNative('openUrl', url);
      } else {
        window.open(url, '_blank');
      }
    } catch (_) {
      window.open(url, '_blank');
    }
    nui('openExternal', { url });
  }

  function findPackage(ident) {
    for (const cat of state.categories) {
      for (const pkg of cat.packages || []) {
        if (String(pkg.ident) === String(ident) || String(pkg.id) === String(ident)) {
          return { pkg, cat };
        }
      }
    }
    return null;
  }

  function updateCartBadge() {
    const count = (state.basket.packages || []).reduce(
      (sum, p) => sum + (Number(p.quantity) || 1),
      0
    );
    if (count > 0) {
      el.cartCount.hidden = false;
      el.cartCount.textContent = String(count);
    } else {
      el.cartCount.hidden = true;
    }
  }

  function setNavActive(view) {
    document.querySelectorAll('[data-view]').forEach((node) => {
      node.classList.toggle('is-active', node.getAttribute('data-view') === view);
    });
  }

  function renderTopbar(ui) {
    const banner = (ui && ui.banner) || [];
    const members = (ui && ui.discordMembers) || 'Discord';
    const items = [
      banner[0] || 'Nieuwe Producten',
      banner[1] || 'Direct Ontvangen',
      members,
      banner[2] || 'Betalen via Tebex',
    ];
    const icons = [
      '<path d="M4 9h16v10a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V9z"/><path d="M4 9l2-5h12l2 5"/>',
      '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
      '<path d="M5 13l4 4L19 7"/>',
      '<rect x="3" y="6" width="18" height="12" rx="2"/><path d="M3 10h18"/>',
    ];
    el.topbar.innerHTML = items
      .map(
        (text, i) => `<span><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">${icons[i]}</svg>${text}</span>`
      )
      .join('');
  }

  function applyBranding(payload) {
    const ui = (payload && payload.ui) || state.ui || {};
    const store = (payload && payload.store) || state.store || {};
    state.ui = ui;
    state.store = store;

    const name = store.name || ui.storeName || 'Eclipse Store';
    el.brandName.textContent = name;
    el.footerLeft.textContent = `© ${ui.serverName || 'Eclipse Roleplay'} — betalingen via Tebex`;

    if (store.logo) {
      el.brandMark.innerHTML = `<img src="${store.logo}" alt="${name}">`;
    }

    const webUrl = store.webstore_url || ui.storeUrl || '#';
    el.webstoreLink.onclick = (e) => {
      e.preventDefault();
      if (webUrl && webUrl !== '#') openExternal(webUrl);
    };

    renderTopbar(ui);

    if (payload && (payload.demo || payload.error)) {
      el.demoBanner.hidden = false;
      el.demoBanner.textContent = payload.error
        || 'Demo-modus: vul Config.PublicToken in om live Tebex-producten en checkout te gebruiken.';
    } else {
      el.demoBanner.hidden = true;
    }
  }

  function renderSidebar() {
    const badgeName = ((state.ui && state.ui.newBadgeCategory) || '').toLowerCase();
    el.catList.innerHTML = state.categories
      .map((cat, index) => {
        const isNew =
          (badgeName && String(cat.name).toLowerCase() === badgeName) ||
          (!badgeName && index === 0);
        const active = String(cat.id) === String(state.activeCategoryId);
        return `<button type="button" class="cat-link${active ? ' is-active' : ''}" data-cat="${cat.id}">
          ${diamond} ${cat.name}
          ${isNew ? '<span class="badge-new">NEW</span>' : ''}
        </button>`;
      })
      .join('');

    el.catList.querySelectorAll('[data-cat]').forEach((btn) => {
      btn.addEventListener('click', () => {
        state.activeCategoryId = btn.getAttribute('data-cat');
        state.view = 'shop';
        state.packageId = null;
        render();
      });
    });
  }

  function packageCard(pkg) {
    const desc = stripHtml(pkg.description) || 'Bekijk dit pakket in de Eclipse Store.';
    const media = pkg.image
      ? `<img src="${pkg.image}" alt="${pkg.name}">`
      : `<div class="pack-art"><strong>${pkg.name}</strong></div>`;
    return `<button type="button" class="product-card" data-package="${pkg.ident || pkg.id}">
      <div class="product-image">${media}</div>
      <div class="product-body">
        <div class="product-name">${diamond} ${pkg.name}</div>
        <div class="product-desc">${desc}</div>
        <div class="product-foot">
          <div class="price">${money(pkg.total_price, pkg.currency)}</div>
          <span class="btn">Bekijken</span>
        </div>
      </div>
    </button>`;
  }

  function renderShop() {
    const cat =
      state.categories.find((c) => String(c.id) === String(state.activeCategoryId)) ||
      state.categories[0];
    if (!cat) {
      el.app.innerHTML = '<p class="empty">Geen categorieën gevonden. Voeg pakketten toe in Tebex.</p>';
      return;
    }
    state.activeCategoryId = cat.id;
    const packages = cat.packages || [];
    el.app.innerHTML = `
      <section class="section-head">
        <h1>${cat.name}</h1>
        ${cat.description ? `<div class="desc">${stripHtml(cat.description)}</div>` : ''}
      </section>
      <div class="product-grid">
        ${packages.length ? packages.map(packageCard).join('') : '<p class="empty">Geen producten in deze categorie.</p>'}
      </div>`;

    el.app.querySelectorAll('[data-package]').forEach((card) => {
      card.addEventListener('click', () => {
        state.view = 'package';
        state.packageId = card.getAttribute('data-package');
        render();
      });
    });
  }

  function renderPackage() {
    const found = findPackage(state.packageId);
    if (!found) {
      state.view = 'shop';
      renderShop();
      return;
    }
    const { pkg, cat } = found;
    state.activeCategoryId = cat.id;
    const media = pkg.image
      ? `<img src="${pkg.image}" alt="${pkg.name}">`
      : `<div class="pack-art"><strong>${pkg.name}</strong></div>`;
    el.app.innerHTML = `
      <article class="detail">
        <div class="detail-media">${media}</div>
        <div>
          <h1>${pkg.name}</h1>
          <div class="muted">${stripHtml(pkg.description) || 'Pakket via Tebex.'}</div>
          <div class="price">${money(pkg.total_price, pkg.currency)}</div>
          <div class="detail-actions">
            <button type="button" class="btn-primary" id="btn-add">In winkelwagen</button>
            <button type="button" class="btn-ghost" id="btn-back">Terug</button>
          </div>
          <p class="muted-note">Betaling verloopt veilig via Tebex. Na aankoop ontvang je je items in-game.</p>
        </div>
      </article>`;

    document.getElementById('btn-back').onclick = () => {
      state.view = 'shop';
      render();
    };
    document.getElementById('btn-add').onclick = () => {
      nui('addToBasket', { ident: pkg.ident || pkg.id });
      toast('Toevoegen aan winkelwagen…');
    };
  }

  function renderBasket() {
    const packages = state.basket.packages || [];
    const rows = packages
      .map((p) => {
        const thumb = p.image
          ? `<img src="${p.image}" alt="${p.name}">`
          : `<div class="pack-art"><strong>${(p.name || '?').slice(0, 8)}</strong></div>`;
        return `<div class="basket-row">
          <div class="basket-thumb">${thumb}</div>
          <div>
            <strong>${p.name || 'Pakket'}</strong>
            <div class="muted-note">Aantal: ${p.quantity || 1}</div>
          </div>
          <div class="basket-price">
            <div class="price">${money(p.price, state.basket.currency)}</div>
            <button type="button" class="btn" data-remove="${p.ident || p.id}">Verwijder</button>
          </div>
        </div>`;
      })
      .join('');

    el.app.innerHTML = `
      <section class="section-head"><h1>Winkelwagen</h1></section>
      <div class="basket-list">
        ${rows || '<p class="empty">Je winkelwagen is leeg.</p>'}
      </div>
      <div class="basket-actions">
        <div class="price">Totaal: ${money(state.basket.total_price, state.basket.currency)}</div>
        <button type="button" class="btn-primary" id="btn-checkout" ${packages.length ? '' : 'disabled'}>Afrekenen</button>
        <button type="button" class="btn-ghost" id="btn-shop">Verder winkelen</button>
        <button type="button" class="btn-ghost" id="btn-web">Open webstore</button>
      </div>
      ${state.basket.authorized ? '<p class="muted-note">Ingelogd bij Tebex — je kunt afrekenen.</p>' : '<p class="muted-note">Bij afrekenen log je eerst in via Tebex (FiveM), daarna opent de checkout.</p>'}
    `;

    el.app.querySelectorAll('[data-remove]').forEach((btn) => {
      btn.addEventListener('click', () => {
        nui('removeFromBasket', { ident: btn.getAttribute('data-remove') });
      });
    });
    const checkout = document.getElementById('btn-checkout');
    if (checkout) {
      checkout.onclick = () => {
        nui('checkout');
        toast('Checkout voorbereiden…');
      };
    }
    document.getElementById('btn-shop').onclick = () => {
      state.view = 'shop';
      render();
    };
    document.getElementById('btn-web').onclick = () => {
      const url = (state.store && state.store.webstore_url) || (state.ui && state.ui.storeUrl);
      openExternal(url);
    };
  }

  function render() {
    if (state.loading) {
      el.app.innerHTML = '<div class="loading-block"><div class="spinner"></div>Catalogus laden…</div>';
      return;
    }
    renderSidebar();
    setNavActive(state.view === 'basket' ? 'basket' : 'shop');
    updateCartBadge();
    if (state.view === 'basket') renderBasket();
    else if (state.view === 'package') renderPackage();
    else renderShop();
  }

  function openUi(msg) {
    state.open = true;
    state.loading = !!msg.loading;
    state.view = 'shop';
    state.packageId = null;
    if (msg.ui) applyBranding({ ui: msg.ui, store: { name: msg.ui.storeName } });
    el.body.classList.remove('nui-hidden');
    el.root.classList.add('is-open');
    el.root.setAttribute('aria-hidden', 'false');
    render();
  }

  function closeUi() {
    state.open = false;
    el.root.classList.remove('is-open');
    el.root.setAttribute('aria-hidden', 'true');
    el.body.classList.add('nui-hidden');
    nui('close');
  }

  function onCatalog(payload) {
    state.loading = false;
    state.demo = !!(payload && payload.demo);
    state.categories = (payload && payload.categories) || [];
    if (!state.activeCategoryId && state.categories[0]) {
      state.activeCategoryId = state.categories[0].id;
    }
    applyBranding(payload || {});
    render();
    nui('getBasket');
  }

  function onBasket(result) {
    if (!result) return;
    if (result.error) toast(result.error, 'error');
    if (result.message) toast(result.message);
    if (result.basket) {
      state.basket = result.basket;
      updateCartBadge();
      if (state.view === 'basket') renderBasket();
      else updateCartBadge();
    }
    if (result.ok && !result.error && state.view === 'package' && !result.needsAuth && !result.demo) {
      state.view = 'basket';
      render();
    }
    if (result.openUrl) openExternal(result.openUrl);
  }

  el.closeBtn.addEventListener('click', closeUi);
  document.querySelectorAll('[data-view]').forEach((node) => {
    node.addEventListener('click', (e) => {
      e.preventDefault();
      const view = node.getAttribute('data-view');
      state.view = view === 'basket' ? 'basket' : 'shop';
      state.packageId = null;
      if (view === 'basket') nui('getBasket');
      render();
    });
  });

  window.addEventListener('keydown', (e) => {
    if (!state.open) return;
    if (e.key === 'Escape') closeUi();
  });

  window.addEventListener('message', (event) => {
    const msg = event.data;
    if (!msg || typeof msg !== 'object') return;

    if (msg.action === 'open') openUi(msg);
    if (msg.action === 'close') {
      state.open = false;
      el.root.classList.remove('is-open');
      el.root.setAttribute('aria-hidden', 'true');
      el.body.classList.add('nui-hidden');
    }
    if (msg.action === 'catalog') onCatalog(msg.payload);
    if (msg.action === 'basket') onBasket(msg.result);
    if (msg.action === 'openUrl') openExternal(msg.url);
  });

  // Local browser preview helper
  if (new URLSearchParams(location.search).has('preview')) {
    openUi({
      loading: false,
      ui: {
        storeName: 'Eclipse Store',
        serverName: 'ECLIPSE RP',
        discordMembers: 'Discord Community',
        banner: ['Nieuwe Producten', 'Direct Ontvangen', 'Betalen via Tebex'],
        newBadgeCategory: 'Coins',
        storeUrl: 'https://eclipserp.tebex.io',
      },
    });
    onCatalog({
      ok: true,
      demo: true,
      store: { name: 'Eclipse Store', webstore_url: 'https://eclipserp.tebex.io', currency: 'EUR' },
      ui: {
        storeName: 'Eclipse Store',
        serverName: 'ECLIPSE RP',
        discordMembers: 'Discord Community',
        banner: ['Nieuwe Producten', 'Direct Ontvangen', 'Betalen via Tebex'],
        newBadgeCategory: 'Coins',
        storeUrl: 'https://eclipserp.tebex.io',
      },
      categories: [
        {
          id: 'coins',
          name: 'Coins',
          description: 'Met deze coins kan je packs kopen via /store in game.',
          packages: [
            { id: 1, ident: 'demo-100', name: '100 Coins', description: 'Coins voor in-game packs.', total_price: 80.99, currency: 'EUR' },
            { id: 2, ident: 'demo-50', name: '50 Coins', description: 'Coins voor in-game packs.', total_price: 40.49, currency: 'EUR' },
            { id: 3, ident: 'demo-25', name: '25 Coins', description: 'Coins voor in-game packs.', total_price: 22.49, currency: 'EUR' },
            { id: 4, ident: 'demo-10', name: '10 Coins', description: 'Coins voor in-game packs.', total_price: 9.99, currency: 'EUR' },
          ],
        },
        {
          id: 'vip',
          name: 'VIP',
          packages: [
            { id: 5, ident: 'demo-vip', name: 'VIP', description: 'VIP rank voor Eclipse RP.', total_price: 14.99, currency: 'EUR' },
          ],
        },
      ],
    });
  }
})();