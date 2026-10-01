/* ==========================================================================
   Ped Tags NUI  —  script.js
   ========================================================================== */

/* --------------------------------------------------------------------------
   Resolutie-scaling
   -------------------------------------------------------------------------- */
(function applyResolutionScale() {
	const baseWidth = 1920;

	const setZoom = () => {
		const scale = Math.sqrt(window.screen.width / baseWidth);
		document.documentElement.style.zoom = scale;
	};

	setZoom();
	window.addEventListener('resize', setZoom);
})();

/* --------------------------------------------------------------------------
   DOM-referenties
   -------------------------------------------------------------------------- */
const tagsLayer    = document.getElementById('tags-layer');
const settingsRoot = document.getElementById('settings');
const avatar       = document.getElementById('avatar');
const discordName  = document.getElementById('discordName');
const discordRank  = document.getElementById('discordRank');

const el = {
	enabled:         document.getElementById('tagEnabled'),
	size:            document.getElementById('tagSize'),
	sizeVal:         document.getElementById('tagSizeVal'),
	bg:              document.getElementById('backgroundOpacity'),
	bgVal:           document.getElementById('bgOpacityVal'),
	borderRadius:    document.getElementById('borderRadius'),
	borderRadiusVal: document.getElementById('borderRadiusVal'),
	showRank:        document.getElementById('showRank'),
	showAvatar:      document.getElementById('showAvatar'),
	save:            document.getElementById('saveBtn'),
	close:           document.getElementById('closeBtn')
};

/* --------------------------------------------------------------------------
   Config & state
   -------------------------------------------------------------------------- */
const DEFAULT_AVATAR = 'https://cdn.discordapp.com/embed/avatars/0.png';

/* Kleuren van het thema (donkerblauw) */
const TAG_BG_RGB   = '5, 20, 40';                  // basiskleur van de tag-achtergrond
const ACCENT_BLUE  = 'rgba(30,122,255,.92)';   // fallback accent-kleur

const DEFAULT_SETTINGS = {
	tagEnabled: true,
	tagSize: 0.7,
	backgroundOpacity: 0.8,
	borderRadius: 20,
	showRank: true,
	showAvatar: true
};

/* --------------------------------------------------------------------------
   NUI helper
   -------------------------------------------------------------------------- */
function postNui(action, data) {
	fetch(`https://${GetParentResourceName()}/${action}`, {
		method: 'POST',
		headers: { 'Content-Type': 'application/json; charset=UTF-8' },
		body: JSON.stringify(data || {})
	}).catch(() => { /* NUI offline — negeren */ });
}

/* --------------------------------------------------------------------------
   Berichten vanuit de client (Lua)
   -------------------------------------------------------------------------- */
window.addEventListener('message', (e) => {
	const data = e.data || {};

	switch (data.action) {
		case 'openSettings':
			applySettings(data.userSettings);
			applyUserInfo(data.userInfo);
			applyUIColor(data.uiColor);
			settingsRoot.classList.remove('hidden');
			break;

		case 'closeSettings':
			settingsRoot.classList.add('hidden');
			break;

		case 'updatePedTags':
			renderTags(data.tags || [], data.userSettings || {});
			break;

		case 'clearAllTags':
			clearTags();
			break;
	}
});

/* --------------------------------------------------------------------------
   Discord-info in het menu
   -------------------------------------------------------------------------- */
function applyUserInfo(info) {
	if (!info) return;

	discordName.textContent = info.name || 'Bestuurslid';
	avatar.src              = info.avatarUrl || DEFAULT_AVATAR;

	if (info.rank) {
		discordRank.textContent = info.rank;
		if (info.rankColor) {
			discordRank.style.color = info.rankColor;
		}
	}
}

/* --------------------------------------------------------------------------
   Settings-formulier
   -------------------------------------------------------------------------- */
function applySettings(s) {
	if (!s) return;

	el.enabled.checked             = !!s.tagEnabled;
	el.size.value                  = s.tagSize ?? DEFAULT_SETTINGS.tagSize;
	el.sizeVal.textContent         = el.size.value;
	el.bg.value                    = s.backgroundOpacity ?? DEFAULT_SETTINGS.backgroundOpacity;
	el.bgVal.textContent           = el.bg.value;
	el.borderRadius.value          = s.borderRadius ?? DEFAULT_SETTINGS.borderRadius;
	el.borderRadiusVal.textContent = el.borderRadius.value;
	el.showRank.checked            = !!s.showRank;
	el.showAvatar.checked          = !!s.showAvatar;

	const preview = document.getElementById('borderRadiusPreview');
	if (preview) {
		preview.style.borderRadius = `${s.borderRadius ?? DEFAULT_SETTINGS.borderRadius}px`;
	}
}

function applyUIColor(color) {
	if (!color) return;
	const root = document.documentElement.style;
	root.setProperty('--accent', color);
	root.setProperty('--accent-hover', color);
	root.setProperty('--shadow-glow', `0 0 22px ${color}`);
}

function currentSettings() {
	return {
		tagEnabled:        el.enabled.checked,
		tagSize:           parseFloat(el.size.value),
		backgroundOpacity: parseFloat(el.bg.value),
		borderRadius:      parseFloat(el.borderRadius.value),
		showRank:          el.showRank.checked,
		showAvatar:        el.showAvatar.checked
	};
}

/* --------------------------------------------------------------------------
   Event listeners
   -------------------------------------------------------------------------- */
if (el.size) {
	el.size.addEventListener('input', () => {
		el.sizeVal.textContent = el.size.value;
	});
}

if (el.bg) {
	el.bg.addEventListener('input', () => {
		el.bgVal.textContent = el.bg.value;
	});
}

if (el.borderRadius) {
	el.borderRadius.addEventListener('input', () => {
		el.borderRadiusVal.textContent = el.borderRadius.value;
		const preview = document.getElementById('borderRadiusPreview');
		if (preview) {
			preview.style.borderRadius = `${el.borderRadius.value}px`;
		}
	});
}

document.querySelectorAll('.tab-nav-btn').forEach((btn) => {
	btn.addEventListener('click', () => {
		const tabName = btn.getAttribute('data-tab');

		document.querySelectorAll('.tab-nav-btn').forEach((b) => b.classList.remove('active'));
		btn.classList.add('active');

		document.querySelectorAll('.tab-panel').forEach((content) => content.classList.remove('active'));
		document.getElementById(`${tabName}-tab`).classList.add('active');
	});
});

if (el.save) {
	el.save.addEventListener('click', () => postNui('saveSettings', currentSettings()));
}

if (el.close) {
	el.close.addEventListener('click', () => postNui('closeSettings'));
}

const closeBtn2 = document.getElementById('closeBtn2');
if (closeBtn2) {
	closeBtn2.addEventListener('click', () => postNui('closeSettings'));
}

/* --------------------------------------------------------------------------
   Tags renderen
   -------------------------------------------------------------------------- */
// key -> bestaand DOM-element + de laatst gezette waarden (om onnodige
// DOM/style writes en met name onnodige <img>-reloads te vermijden — dat
// veroorzaakte het schokkerige/knipperende gevoel bij elke update).
const tagElements = new Map();

function clearTags() {
	tagsLayer.innerHTML = '';
	tagElements.clear();
}

function resolveEffectiveSettings(t, settings) {
	const isSelf = t.isSelf;
	const owner  = t.ownerSettings || {};

	return {
		tagEnabled:        isSelf ? settings.tagEnabled        : (owner.tagEnabled !== false),
		tagSize:           isSelf ? settings.tagSize           : (owner.tagSize ?? DEFAULT_SETTINGS.tagSize),
		backgroundOpacity: isSelf ? settings.backgroundOpacity : (owner.backgroundOpacity ?? DEFAULT_SETTINGS.backgroundOpacity),
		borderRadius:      isSelf ? (settings.borderRadius ?? DEFAULT_SETTINGS.borderRadius) : (owner.borderRadius ?? DEFAULT_SETTINGS.borderRadius),
		showRank:          isSelf ? settings.showRank          : (owner.showRank !== false),
		showAvatar:        isSelf ? settings.showAvatar        : (owner.showAvatar !== false)
	};
}

// Bouwt de vaste DOM-structuur van een tag ÉÉN keer op (avatar, naam, rank).
// Wordt hierna alleen nog via updateTagElement() bijgewerkt, niet opnieuw aangemaakt.
function createTagElement() {
	const tag = document.createElement('div');
	tag.className = 'tag';

	const cornersOverlay = document.createElement('div');
	cornersOverlay.className = 'corners-overlay';
	tag.appendChild(cornersOverlay);

	const avWrap = document.createElement('div');
	avWrap.className = 'av-wrap';

	const img = document.createElement('img');
	img.className = 'avatar';
	img.style.borderRadius = '50%';
	avWrap.appendChild(img);

	const dot = document.createElement('div');
	dot.className = 'online-dot';
	avWrap.appendChild(dot);
	tag.appendChild(avWrap);

	const divider = document.createElement('div');
	divider.className = 'tag-divider';
	tag.appendChild(divider);

	const text = document.createElement('div');
	text.className = 'text';

	const name = document.createElement('div');
	name.className = 'name';
	text.appendChild(name);

	const rank = document.createElement('div');
	rank.className = 'rank';
	text.appendChild(rank);

	tag.appendChild(text);

	tag._refs = { avWrap, img, divider, name, rank };
	tag._last = {};

	return tag;
}

// Werkt een bestaand tag-element bij, en raakt alleen de dingen aan die
// daadwerkelijk veranderd zijn sinds de vorige update (voorkomt onnodige
// reflows en, belangrijker, voorkomt dat de <img> steeds opnieuw laadt).
function updateTagElement(tag, t, effective) {
	const { avWrap, img, divider, name, rank } = tag._refs;
	const last = tag._last;
	const currentZoom = parseFloat(document.documentElement.style.zoom) || 1.0;

	const distanceFactor = 5.0 / Math.max(5.0, t.distance);
	const scale = effective.tagSize * distanceFactor;
	const accentColor = t.rankColor || ACCENT_BLUE;

	const left = `${t.screenX / currentZoom}%`;
	const top = `${t.screenY / currentZoom}%`;
	const transform = `translate(-50%, -50%) scale(${scale})`;

	if (last.left !== left) { tag.style.left = left; last.left = left; }
	if (last.top !== top) { tag.style.top = top; last.top = top; }
	if (last.transform !== transform) { tag.style.transform = transform; last.transform = transform; }

	const background = `rgba(${TAG_BG_RGB}, ${effective.backgroundOpacity})`;
	if (last.background !== background) { tag.style.background = background; last.background = background; }

	const borderRadius = `${effective.borderRadius}px`;
	if (last.borderRadius !== borderRadius) { tag.style.borderRadius = borderRadius; last.borderRadius = borderRadius; }

	if (effective.showAvatar) {
		avWrap.style.display = '';
		divider.style.display = '';
		const avatarUrl = t.avatarUrl || DEFAULT_AVATAR;
		if (last.avatarUrl !== avatarUrl) { img.src = avatarUrl; last.avatarUrl = avatarUrl; }
	} else {
		avWrap.style.display = 'none';
		divider.style.display = 'none';
	}

	if (last.name !== t.name) { name.textContent = t.name || 'Staff'; last.name = t.name; }

	if (effective.showRank && t.rank) {
		rank.style.display = '';
		if (last.rank !== t.rank) { rank.textContent = t.rank; last.rank = t.rank; }
		if (last.rankColor !== accentColor) { rank.style.color = accentColor; last.rankColor = accentColor; }
	} else {
		rank.style.display = 'none';
	}
}

function renderTags(tags, settings) {
	if (tagsLayer) {
		tagsLayer.style.display = 'block';
		tagsLayer.style.opacity = '1';
	}
	document.body.style.display = 'block';
	document.body.style.opacity = '1';

	const seen = new Set();

	for (const t of tags) {
		const effective = resolveEffectiveSettings(t, settings);
		if (!effective.tagEnabled) continue;

		const key = t.serverId ?? t.id ?? t.name;
		seen.add(key);

		let tag = tagElements.get(key);
		if (!tag) {
			tag = createTagElement();
			tagElements.set(key, tag);
			tagsLayer.appendChild(tag);
		}

		updateTagElement(tag, t, effective);
	}

	// Verwijder tags van staff die niet meer in de lijst zitten (uit beeld/bereik).
	for (const [key, tag] of tagElements) {
		if (!seen.has(key)) {
			tag.remove();
			tagElements.delete(key);
		}
	}
}

/* --------------------------------------------------------------------------
   Klaar
   -------------------------------------------------------------------------- */
postNui('uiReady');