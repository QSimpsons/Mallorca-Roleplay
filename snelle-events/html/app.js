const panel = document.getElementById('panel');
const joinMenu = document.getElementById('joinMenu');
const eventHud = document.getElementById('eventHud');
const passwordModal = document.getElementById('passwordModal');
const inviteModal = document.getElementById('inviteModal');
const announceModal = document.getElementById('announceModal');

let panelData = null;
let currentHudEvent = null;
let managedEvent = null;
let isHost = false;
let pendingPasswordEventId = null;
let onlinePlayers = [];
let menuOpen = false;

function resourceName() {
    try {
        return GetParentResourceName();
    } catch (e) {
        return 'snelle-events';
    }
}

function post(endpoint, data = {}) {
    return fetch(`https://${resourceName()}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data)
    }).catch(() => null);
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text || '';
    return div.innerHTML;
}

function closeAll() {
    try {
        panel.classList.add('hidden');
        joinMenu.classList.add('hidden');
        passwordModal.classList.add('hidden');
        inviteModal.classList.add('hidden');
        if (announceModal) announceModal.classList.add('hidden');
    } catch (e) {}

    menuOpen = false;
    pendingPasswordEventId = null;
    post('close');
}

function openAnnounceModal() {
    if (!managedEvent || !announceModal) return;
    document.getElementById('announceInput').value = '';
    announceModal.classList.remove('hidden');
    document.getElementById('announceInput').focus();
}

function switchTab(tabName) {
    document.querySelectorAll('.tab').forEach(t => t.classList.toggle('active', t.dataset.tab === tabName));
    document.querySelectorAll('.tab-content').forEach(c => c.classList.toggle('active', c.id === `tab-${tabName}`));
}

function populateEventTypes(types) {
    const select = document.getElementById('eventType');
    select.innerHTML = '';
    for (const [key, cfg] of Object.entries(types || {})) {
        const opt = document.createElement('option');
        opt.value = key;
        opt.textContent = cfg.label;
        select.appendChild(opt);
    }

    const applyType = () => {
        const cfg = types[select.value];
        if (!cfg) return;
        document.getElementById('maxPlayers').value = cfg.defaultMaxPlayers || 32;
        document.getElementById('minPlayers').value = cfg.defaultMinPlayers || 1;
        document.getElementById('eventDescription').value = cfg.description || '';
        document.getElementById('allowWeapons').checked = !!cfg.allowWeapons;
        document.getElementById('pvpEnabled').checked = !!cfg.pvpEnabled;
        document.getElementById('freezeOnStart').checked = !!cfg.freezeOnStart;
        document.getElementById('enforceZone').checked = !!cfg.enforceZone;
        document.getElementById('zoneRadius').value = cfg.zoneRadius || 80;
        document.getElementById('duration').value = cfg.duration || 0;
        document.getElementById('scoreToWin').value = cfg.scoreToWin || 0;
        document.getElementById('vehicle').value = cfg.vehicle || '';
        document.getElementById('finishRow').style.display = select.value === 'race' ? 'grid' : 'none';
    };

    select.onchange = applyType;
    applyType();
}

function populatePresets(presets) {
    const select = document.getElementById('locationPreset');
    select.innerHTML = '<option value="">Huidige positie</option>';
    (presets || []).forEach((preset, index) => {
        const opt = document.createElement('option');
        opt.value = index;
        opt.textContent = preset.name;
        select.appendChild(opt);
    });

    select.onchange = () => {
        if (select.value === '') return;
        const preset = presets[parseInt(select.value)];
        setCoords(preset.coords, preset.heading);
    };
}

function setCoords(coords, heading) {
    if (!coords) return;
    document.getElementById('coordX').value = Number(coords.x).toFixed(2);
    document.getElementById('coordY').value = Number(coords.y).toFixed(2);
    document.getElementById('coordZ').value = Number(coords.z).toFixed(2);
    document.getElementById('coordH').value = Number(heading || coords.heading || 0).toFixed(1);
}

function renderEventsList(container, events, options = {}) {
    container.innerHTML = '';
    if (!events || events.length === 0) {
        container.innerHTML = '<div class="empty-state">Geen actieve events</div>';
        return;
    }

    events.forEach(event => {
        const card = document.createElement('div');
        card.className = 'event-card';
        const lock = event.hasPassword ? ' 🔒' : '';
        card.innerHTML = `
            <div class="event-card-info">
                <h3>${escapeHtml(event.name)}${lock}</h3>
                <p>${escapeHtml(event.typeLabel)} · ${event.playerCount}/${event.maxPlayers} · Host: ${escapeHtml(event.host)} · min ${event.minPlayers || 1}</p>
            </div>
            <div class="event-card-actions">
                <span class="status-badge ${event.status}">${escapeHtml(event.statusLabel)}</span>
            </div>`;

        const actions = card.querySelector('.event-card-actions');

        if (options.joinable && event.status === 'waiting') {
            const joinBtn = document.createElement('button');
            joinBtn.className = 'btn small primary';
            joinBtn.textContent = 'Deelnemen';
            joinBtn.onclick = () => {
                if (event.hasPassword) {
                    pendingPasswordEventId = event.id;
                    document.getElementById('passwordTitle').textContent = `Wachtwoord: ${event.name}`;
                    passwordModal.classList.remove('hidden');
                } else {
                    post('joinEvent', { eventId: event.id });
                }
            };
            actions.prepend(joinBtn);
        }

        if (options.manageable) {
            if (event.status === 'waiting') {
                const startBtn = document.createElement('button');
                startBtn.className = 'btn small primary';
                startBtn.textContent = 'Start';
                startBtn.onclick = () => post('startEvent', { eventId: event.id });
                actions.prepend(startBtn);
            }

            if (event.status !== 'ended') {
                const stopBtn = document.createElement('button');
                stopBtn.className = 'btn small danger';
                stopBtn.textContent = 'Stop';
                stopBtn.onclick = () => post('stopEvent', { eventId: event.id });
                actions.prepend(stopBtn);

                const manageBtn = document.createElement('button');
                manageBtn.className = 'btn small secondary';
                manageBtn.textContent = 'Beheer';
                manageBtn.onclick = () => {
                    document.getElementById('manageEventSelect').value = event.id;
                    post('getEventDetail', { eventId: event.id });
                    switchTab('manage');
                };
                actions.prepend(manageBtn);
            }
        }

        container.appendChild(card);
    });
}

function updateManageSelect(events) {
    const select = document.getElementById('manageEventSelect');
    const current = select.value;
    select.innerHTML = '<option value="">— kies event —</option>';
    (events || []).forEach(e => {
        const opt = document.createElement('option');
        opt.value = e.id;
        opt.textContent = `${e.name} (${e.statusLabel})`;
        select.appendChild(opt);
    });
    if (current) select.value = current;
}

function renderRoster(event) {
    const list = document.getElementById('rosterList');
    list.innerHTML = '';
    if (!event.players || event.players.length === 0) {
        list.innerHTML = '<div class="empty-state">Geen spelers</div>';
        return;
    }

    event.players.forEach(p => {
        const row = document.createElement('div');
        row.className = 'roster-row';
        const role = p.role ? ` · ${p.role}` : '';
        const elim = p.eliminated ? ' · OUT' : '';
        row.innerHTML = `
            <div>
                <div class="name">${escapeHtml(p.name)}${p.isHost ? ' 👑' : ''}</div>
                <div class="meta">ID ${p.id} · K:${p.kills || 0} D:${p.deaths || 0}${role}${elim}</div>
            </div>
            <div class="actions"></div>`;

        const actions = row.querySelector('.actions');

        if (!p.isHost) {
            const kick = document.createElement('button');
            kick.className = 'btn small danger';
            kick.textContent = 'Kick';
            kick.onclick = () => post('kickPlayer', { eventId: event.id, targetId: p.id });
            actions.appendChild(kick);

            const promote = document.createElement('button');
            promote.className = 'btn small secondary';
            promote.textContent = 'Host';
            promote.onclick = () => post('promoteHost', { eventId: event.id, targetId: p.id });
            actions.appendChild(promote);
        }

        if (!p.eliminated) {
            const win = document.createElement('button');
            win.className = 'btn small primary';
            win.textContent = 'Win';
            win.onclick = () => post('setWinner', { eventId: event.id, winnerId: p.id });
            actions.appendChild(win);
        }

        list.appendChild(row);
    });
}

function showManageDetail(event) {
    managedEvent = event;
    document.getElementById('manageEmpty').classList.add('hidden');
    document.getElementById('manageDetail').classList.remove('hidden');
    document.getElementById('manageName').textContent = event.name;
    document.getElementById('manageMeta').textContent =
        `${event.typeLabel} · ${event.playerCount}/${event.maxPlayers} · ${event.statusLabel} · Host: ${event.host}`;
    document.getElementById('manageStart').classList.toggle('hidden', event.status !== 'waiting');
    renderRoster(event);
}

function showEventHud(event, host) {
    currentHudEvent = event;
    isHost = host;

    document.getElementById('hudEventName').textContent = event.name;
    document.getElementById('hudEventType').textContent = event.typeLabel || event.type;
    document.getElementById('hudPlayerCount').textContent = `${event.playerCount || 0}/${event.maxPlayers}`;
    document.getElementById('hudStatus').textContent = event.statusLabel || event.status;
    document.getElementById('hudStatus').className = `status-badge ${event.status}`;
    document.getElementById('hudStart').classList.toggle('hidden', !isHost || event.status !== 'waiting');
    document.getElementById('hudStop').classList.toggle('hidden', !isHost);

    const board = document.getElementById('hudScoreboard');
    board.innerHTML = '';
    (event.players || []).slice(0, 8).forEach(p => {
        const row = document.createElement('div');
        row.className = 'row';
        row.innerHTML = `<span>${escapeHtml(p.name)}${p.eliminated ? ' ✕' : ''}</span><span>${p.kills || 0}/${p.deaths || 0}</span>`;
        board.appendChild(row);
    });

    eventHud.classList.remove('hidden');
}

function hideEventHud() {
    eventHud.classList.add('hidden');
    currentHudEvent = null;
    document.getElementById('hudCountdown').classList.add('hidden');
}

document.getElementById('closePanel').onclick = closeAll;
document.getElementById('closeJoin').onclick = closeAll;
document.querySelectorAll('.tab').forEach(tab => {
    tab.onclick = () => switchTab(tab.dataset.tab);
});

document.getElementById('useCurrentCoords').onclick = async () => {
    try {
        const res = await post('getCurrentCoords');
        if (!res) return;
        const coords = await res.json();
        setCoords(coords);
    } catch (e) {}
};

document.getElementById('useFinishCoords').onclick = async () => {
    try {
        const res = await post('getCurrentCoords');
        if (!res) return;
        const coords = await res.json();
        document.getElementById('finishX').value = Number(coords.x).toFixed(2);
        document.getElementById('finishY').value = Number(coords.y).toFixed(2);
        document.getElementById('finishZ').value = Number(coords.z).toFixed(2);
    } catch (e) {}
};

document.getElementById('createEventBtn').onclick = () => {
    const finishX = document.getElementById('finishX').value;
    const data = {
        name: document.getElementById('eventName').value,
        type: document.getElementById('eventType').value,
        minPlayers: parseInt(document.getElementById('minPlayers').value),
        maxPlayers: parseInt(document.getElementById('maxPlayers').value),
        countdown: parseInt(document.getElementById('countdown').value),
        zoneRadius: parseFloat(document.getElementById('zoneRadius').value),
        duration: parseInt(document.getElementById('duration').value) || 0,
        scoreToWin: parseInt(document.getElementById('scoreToWin').value) || 0,
        vehicle: document.getElementById('vehicle').value || null,
        password: document.getElementById('password').value || null,
        description: document.getElementById('eventDescription').value,
        allowWeapons: document.getElementById('allowWeapons').checked,
        pvpEnabled: document.getElementById('pvpEnabled').checked,
        freezeOnStart: document.getElementById('freezeOnStart').checked,
        enforceZone: document.getElementById('enforceZone').checked,
        coords: {
            x: parseFloat(document.getElementById('coordX').value),
            y: parseFloat(document.getElementById('coordY').value),
            z: parseFloat(document.getElementById('coordZ').value),
            heading: parseFloat(document.getElementById('coordH').value)
        }
    };

    if (finishX) {
        data.finishCoords = {
            x: parseFloat(document.getElementById('finishX').value),
            y: parseFloat(document.getElementById('finishY').value),
            z: parseFloat(document.getElementById('finishZ').value),
            heading: 0
        };
    }

    post('createEvent', data);
    switchTab('active');
};

document.getElementById('refreshEvents').onclick = () => post('refreshEvents');
document.getElementById('loadManageEvent').onclick = () => {
    const id = document.getElementById('manageEventSelect').value;
    if (id) post('getEventDetail', { eventId: id });
};

document.getElementById('manageStart').onclick = () => managedEvent && post('startEvent', { eventId: managedEvent.id });
document.getElementById('manageStop').onclick = () => managedEvent && post('stopEvent', { eventId: managedEvent.id });
document.getElementById('manageTeleport').onclick = () => managedEvent && post('teleportAll', { eventId: managedEvent.id });
document.getElementById('manageAnnounce').onclick = openAnnounceModal;

if (announceModal) {
    document.getElementById('announceCancel').onclick = () => announceModal.classList.add('hidden');
    document.getElementById('announceConfirm').onclick = () => {
        const msg = (document.getElementById('announceInput').value || '').trim();
        if (managedEvent && msg) {
            post('announceEvent', { eventId: managedEvent.id, message: msg });
        }
        announceModal.classList.add('hidden');
    };
}

document.getElementById('loadOnlinePlayers').onclick = () => post('getOnlinePlayers');
document.getElementById('sendInviteBtn').onclick = () => {
    const targetId = parseInt(document.getElementById('invitePlayerSelect').value);
    if (managedEvent && targetId) post('invitePlayer', { eventId: managedEvent.id, targetId });
};

document.getElementById('passwordCancel').onclick = () => {
    passwordModal.classList.add('hidden');
    pendingPasswordEventId = null;
    if (panel.classList.contains('hidden') && joinMenu.classList.contains('hidden')) {
        closeAll();
    }
};

document.getElementById('passwordConfirm').onclick = () => {
    const password = document.getElementById('passwordInput').value;
    if (pendingPasswordEventId) {
        post('joinEvent', { eventId: pendingPasswordEventId, password });
    }
    passwordModal.classList.add('hidden');
    pendingPasswordEventId = null;
};

document.getElementById('inviteDecline').onclick = () => {
    inviteModal.classList.add('hidden');
    closeAll();
};

document.getElementById('inviteAccept').onclick = () => {
    post('acceptInvite');
    inviteModal.classList.add('hidden');
};

document.getElementById('hudStart').onclick = () => currentHudEvent && post('startEvent', { eventId: currentHudEvent.id });
document.getElementById('hudStop').onclick = () => currentHudEvent && post('stopEvent', { eventId: currentHudEvent.id });
document.getElementById('hudLeave').onclick = () => post('leaveEvent');

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        e.preventDefault();
        closeAll();
        return;
    }

    if (e.key === 'Backspace') {
        const tag = (document.activeElement && document.activeElement.tagName) || '';
        if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT') return;
        e.preventDefault();
        closeAll();
    }
});

window.addEventListener('message', (event) => {
    const data = event.data || {};
    const action = data.action;

    try {
        switch (action) {
            case 'forceClose':
                panel.classList.add('hidden');
                joinMenu.classList.add('hidden');
                passwordModal.classList.add('hidden');
                inviteModal.classList.add('hidden');
                if (announceModal) announceModal.classList.add('hidden');
                menuOpen = false;
                break;

            case 'openPanel':
                panelData = data.data || {};
                populateEventTypes(panelData.eventTypes);
                populatePresets(panelData.presets || []);
                if (panelData.playerCoords) setCoords(panelData.playerCoords);
                renderEventsList(document.getElementById('eventsList'), panelData.events, { manageable: true });
                updateManageSelect(panelData.events);
                panel.classList.remove('hidden');
                menuOpen = true;
                break;

            case 'panelData':
                if (data.data && data.data.events) {
                    renderEventsList(document.getElementById('eventsList'), data.data.events, { manageable: true });
                    updateManageSelect(data.data.events);
                }
                if (data.data && data.data.currentEvent) {
                    showManageDetail(data.data.currentEvent);
                }
                break;

            case 'openJoin':
                renderEventsList(document.getElementById('joinList'), data.events, { joinable: true });
                joinMenu.classList.remove('hidden');
                menuOpen = true;
                break;

            case 'syncEvents':
                if (!panel.classList.contains('hidden')) {
                    renderEventsList(document.getElementById('eventsList'), data.events, { manageable: true });
                    updateManageSelect(data.events);
                }
                break;

            case 'showEventHud':
                showEventHud(data.event, data.isHost);
                break;

            case 'hideEventHud':
                hideEventHud();
                break;

            case 'countdown':
                document.getElementById('hudCountdown').textContent = data.seconds;
                document.getElementById('hudCountdown').classList.remove('hidden');
                break;

            case 'eventStarted':
                showEventHud(data.event, isHost);
                document.getElementById('hudCountdown').classList.add('hidden');
                break;

            case 'eventUpdate':
                if (currentHudEvent && data.event && currentHudEvent.id === data.event.id) {
                    showEventHud(data.event, isHost);
                }
                if (managedEvent && data.event && managedEvent.id === data.event.id) {
                    showManageDetail(data.event);
                }
                break;

            case 'becameHost':
                isHost = true;
                showEventHud(data.event, true);
                break;

            case 'updatePlayerCount':
                document.getElementById('hudPlayerCount').textContent =
                    `${data.count}/${currentHudEvent?.maxPlayers || '?'}`;
                break;

            case 'askPassword':
                pendingPasswordEventId = data.eventId;
                document.getElementById('passwordTitle').textContent = `Wachtwoord: ${data.eventName}`;
                passwordModal.classList.remove('hidden');
                menuOpen = true;
                break;

            case 'showInvite':
                document.getElementById('inviteText').textContent =
                    `${data.data.fromName} nodigt je uit voor "${data.data.eventName}"`;
                inviteModal.classList.remove('hidden');
                menuOpen = true;
                break;

            case 'onlinePlayers':
                onlinePlayers = data.players || [];
                const sel = document.getElementById('invitePlayerSelect');
                sel.innerHTML = '';
                onlinePlayers.filter(p => !p.inEvent).forEach(p => {
                    const opt = document.createElement('option');
                    opt.value = p.id;
                    opt.textContent = `${p.name} (${p.id})`;
                    sel.appendChild(opt);
                });
                sel.classList.remove('hidden');
                document.getElementById('sendInviteBtn').classList.remove('hidden');
                break;

            case 'eliminated':
                if (data.event) showEventHud(data.event, isHost);
                break;
        }
    } catch (err) {
        console.log('[snelle-events] NUI error', err);
    }
});
