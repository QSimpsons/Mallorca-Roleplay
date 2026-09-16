const panel = document.getElementById('panel');
const joinMenu = document.getElementById('joinMenu');
const eventHud = document.getElementById('eventHud');

let panelData = null;
let currentHudEvent = null;
let isHost = false;

function post(endpoint, data = {}) {
    return fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });
}

function closeAll() {
    panel.classList.add('hidden');
    joinMenu.classList.add('hidden');
    post('close');
}

function switchTab(tabName) {
    document.querySelectorAll('.tab').forEach(t => t.classList.toggle('active', t.dataset.tab === tabName));
    document.querySelectorAll('.tab-content').forEach(c => c.classList.toggle('active', c.id === `tab-${tabName}`));
}

function populateEventTypes(types) {
    const select = document.getElementById('eventType');
    select.innerHTML = '';

    for (const [key, cfg] of Object.entries(types)) {
        const opt = document.createElement('option');
        opt.value = key;
        opt.textContent = cfg.label;
        select.appendChild(opt);
    }

    select.addEventListener('change', () => {
        const cfg = types[select.value];
        if (cfg) {
            document.getElementById('maxPlayers').value = cfg.defaultMaxPlayers;
            document.getElementById('eventDescription').value = cfg.description || '';
            document.getElementById('allowWeapons').checked = cfg.allowWeapons || false;
            document.getElementById('pvpEnabled').checked = cfg.pvpEnabled || false;
            document.getElementById('freezeOnStart').checked = cfg.freezeOnStart || false;
        }
    });

    select.dispatchEvent(new Event('change'));
}

function populatePresets(presets) {
    const select = document.getElementById('locationPreset');
    select.innerHTML = '<option value="">Huidige positie</option>';

    presets.forEach((preset, index) => {
        const opt = document.createElement('option');
        opt.value = index;
        opt.textContent = preset.name;
        select.appendChild(opt);
    });

    select.addEventListener('change', () => {
        if (select.value === '') return;
        const preset = presets[parseInt(select.value)];
        document.getElementById('coordX').value = preset.coords.x.toFixed(2);
        document.getElementById('coordY').value = preset.coords.y.toFixed(2);
        document.getElementById('coordZ').value = preset.coords.z.toFixed(2);
        document.getElementById('coordH').value = preset.heading.toFixed(1);
    });
}

function setCoords(coords) {
    document.getElementById('coordX').value = coords.x.toFixed(2);
    document.getElementById('coordY').value = coords.y.toFixed(2);
    document.getElementById('coordZ').value = coords.z.toFixed(2);
    document.getElementById('coordH').value = (coords.heading || 0).toFixed(1);
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

        card.innerHTML = `
            <div class="event-card-info">
                <h3>${escapeHtml(event.name)}</h3>
                <p>${escapeHtml(event.typeLabel)} · ${event.playerCount}/${event.maxPlayers} spelers · Host: ${escapeHtml(event.host)}</p>
            </div>
            <div class="event-card-actions">
                <span class="status-badge ${event.status}">${escapeHtml(event.statusLabel)}</span>
            </div>
        `;

        const actions = card.querySelector('.event-card-actions');

        if (options.joinable && event.status === 'waiting') {
            const joinBtn = document.createElement('button');
            joinBtn.className = 'btn small primary';
            joinBtn.textContent = 'Deelnemen';
            joinBtn.onclick = () => post('joinEvent', { eventId: event.id });
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

                const announceBtn = document.createElement('button');
                announceBtn.className = 'btn small secondary';
                announceBtn.textContent = 'Aankondiging';
                announceBtn.onclick = () => {
                    const msg = prompt('Aankondiging bericht:');
                    if (msg) post('announceEvent', { eventId: event.id, message: msg });
                };
                actions.prepend(announceBtn);
            }
        }

        container.appendChild(card);
    });
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text || '';
    return div.innerHTML;
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

    eventHud.classList.remove('hidden');
}

function hideEventHud() {
    eventHud.classList.add('hidden');
    currentHudEvent = null;
    document.getElementById('hudCountdown').classList.add('hidden');
}

// Event listeners
document.getElementById('closePanel').addEventListener('click', closeAll);
document.getElementById('closeJoin').addEventListener('click', closeAll);

document.querySelectorAll('.tab').forEach(tab => {
    tab.addEventListener('click', () => switchTab(tab.dataset.tab));
});

document.getElementById('useCurrentCoords').addEventListener('click', async () => {
    const coords = await post('getCurrentCoords').then(r => r.json());
    setCoords(coords);
});

document.getElementById('createEventBtn').addEventListener('click', () => {
    const data = {
        name: document.getElementById('eventName').value,
        type: document.getElementById('eventType').value,
        maxPlayers: parseInt(document.getElementById('maxPlayers').value),
        countdown: parseInt(document.getElementById('countdown').value),
        description: document.getElementById('eventDescription').value,
        allowWeapons: document.getElementById('allowWeapons').checked,
        pvpEnabled: document.getElementById('pvpEnabled').checked,
        freezeOnStart: document.getElementById('freezeOnStart').checked,
        coords: {
            x: parseFloat(document.getElementById('coordX').value),
            y: parseFloat(document.getElementById('coordY').value),
            z: parseFloat(document.getElementById('coordZ').value),
            heading: parseFloat(document.getElementById('coordH').value)
        }
    };

    post('createEvent', data);
    switchTab('active');
});

document.getElementById('refreshEvents').addEventListener('click', () => post('refreshEvents'));

document.getElementById('hudStart').addEventListener('click', () => {
    if (currentHudEvent) post('startEvent', { eventId: currentHudEvent.id });
});

document.getElementById('hudStop').addEventListener('click', () => {
    if (currentHudEvent) post('stopEvent', { eventId: currentHudEvent.id });
});

document.getElementById('hudLeave').addEventListener('click', () => post('leaveEvent'));

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeAll();
});

window.addEventListener('message', (event) => {
    const { action } = event.data;

    switch (action) {
        case 'openPanel':
            panelData = event.data.data;
            populateEventTypes(panelData.eventTypes);
            populatePresets(panelData.presets || []);
            if (panelData.playerCoords) setCoords(panelData.playerCoords);
            renderEventsList(document.getElementById('eventsList'), panelData.events, { manageable: true });
            panel.classList.remove('hidden');
            break;

        case 'panelData':
            if (event.data.data.events) {
                renderEventsList(document.getElementById('eventsList'), event.data.data.events, { manageable: true });
            }
            break;

        case 'openJoin':
            renderEventsList(document.getElementById('joinList'), event.data.events, { joinable: true });
            joinMenu.classList.remove('hidden');
            break;

        case 'syncEvents':
            if (!panel.classList.contains('hidden')) {
                renderEventsList(document.getElementById('eventsList'), event.data.events, { manageable: true });
            }
            break;

        case 'showEventHud':
            showEventHud(event.data.event, event.data.isHost);
            break;

        case 'hideEventHud':
            hideEventHud();
            break;

        case 'countdown':
            const cd = document.getElementById('hudCountdown');
            cd.textContent = event.data.seconds;
            cd.classList.remove('hidden');
            break;

        case 'eventStarted':
            showEventHud(event.data.event, isHost);
            document.getElementById('hudCountdown').classList.add('hidden');
            break;

        case 'becameHost':
            isHost = true;
            showEventHud(event.data.event, true);
            break;

        case 'updatePlayerCount':
            document.getElementById('hudPlayerCount').textContent =
                `${event.data.count}/${currentHudEvent?.maxPlayers || '?'}`;
            break;
    }
});
