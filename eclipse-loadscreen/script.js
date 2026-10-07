const statusLabel = document.getElementById("status-label");
const slotsLabel = document.getElementById("slots");
const welcome = document.getElementById("welcome");
const discordButton = document.getElementById("discord");
const staffPanel = document.getElementById("staff");
const staffTitle = document.getElementById("staff-title");
const staffList = document.getElementById("staff-list");
const rulesTitle = document.getElementById("rules-title");
const rulesList = document.getElementById("rules");
const loadStatus = document.getElementById("load-status");
const loadPct = document.getElementById("load-pct");
const loadBar = document.getElementById("load-bar");
const loadLog = document.getElementById("load-log");
const tip = document.getElementById("tip");
const keys = document.getElementById("keys");
const musicPanel = document.getElementById("music");
const musicToggle = document.getElementById("music-toggle");
const musicTitle = document.getElementById("music-title");
const iconPause = document.getElementById("icon-pause");
const iconPlay = document.getElementById("icon-play");
const volumeInput = document.getElementById("volume");
const hint = document.getElementById("hint");
const theme = document.getElementById("theme");
const video = document.getElementById("bg");

const handover = window.nuiHandoverData || {};
let targetProgress = 0;
let shownProgress = 0;
let sawLoadProgress = false;
let tipIndex = 0;
let musicPaused = false;

function clamp01(value) {
    return Math.max(0, Math.min(1, value));
}

function statusFor(fraction) {
    if (fraction < 0.08) return "Verbinden";
    if (fraction < 0.30) return "Bestanden laden";
    if (fraction < 0.55) return "Wereld opbouwen";
    if (fraction < 0.82) return "Resources starten";
    if (fraction < 0.97) return "Bijna binnen";
    return "Welkom in de stad";
}

function paintProgress(fraction) {
    const pct = Math.round(fraction * 100);
    loadBar.style.width = pct + "%";
    loadPct.textContent = pct + "%";
    loadStatus.textContent = statusFor(fraction);
}

function setProgress(fraction) {
    const next = clamp01(fraction);
    if (next < targetProgress) return;
    targetProgress = next;
}

function animateProgress() {
    shownProgress += (targetProgress - shownProgress) * 0.14;
    if (Math.abs(targetProgress - shownProgress) < 0.001) {
        shownProgress = targetProgress;
    }
    paintProgress(shownProgress);
    requestAnimationFrame(animateProgress);
}

function setLog(message) {
    if (!Config.showLog || typeof message !== "string") return;
    const clean = message.replace(/\s+/g, " ").trim();
    if (!clean) return;
    loadLog.textContent = clean.slice(0, 110);
}

function showTip(index) {
    const tips = Config.tips || [];
    if (!tips.length) return;
    tip.classList.add("is-fading");
    window.setTimeout(() => {
        tip.textContent = tips[index % tips.length];
        tip.classList.remove("is-fading");
    }, 280);
}

function startTips() {
    const tips = Config.tips || [];
    if (!tips.length) return;
    tip.textContent = tips[0];
    if (tips.length === 1) return;
    window.setInterval(() => {
        tipIndex = (tipIndex + 1) % tips.length;
        showTip(tipIndex);
    }, Config.tipInterval || 6500);
}

function renderStatic() {
    statusLabel.textContent = Config.statusLabel || "Server online";
    if (Config.slots) {
        slotsLabel.hidden = false;
        slotsLabel.textContent = String(Config.slots) + " slots";
    }

    const playerName = typeof handover.name === "string" ? handover.name.trim() : "";
    if (playerName) {
        welcome.hidden = false;
        welcome.textContent = "Welkom, " + playerName;
    }

    discordButton.textContent = Config.discordLabel || "";

    renderStaff();

    rulesTitle.textContent = Config.rulesTitle || "";
    rulesList.replaceChildren();
    (Config.rules || []).forEach((rule) => {
        const item = document.createElement("li");
        item.textContent = rule;
        rulesList.appendChild(item);
    });

    keys.replaceChildren();
    (Config.keys || []).forEach((binding) => {
        const item = document.createElement("span");
        const key = document.createElement("kbd");
        key.textContent = binding.key;
        item.append(key, document.createTextNode(binding.label));
        keys.appendChild(item);
    });

    hint.textContent = Config.hint || "";
}

function renderStaff() {
    const staff = Config.staff || {};
    const members = (staff.members || []).filter((member) => {
        return member && typeof member.name === "string" && member.name.trim() && typeof member.role === "string" && member.role.trim();
    });

    staffList.replaceChildren();
    if (staff.enabled === false || members.length === 0) {
        staffPanel.hidden = true;
        return;
    }

    staffTitle.textContent = staff.title || "Staffteam";
    members.forEach((member) => {
        const item = document.createElement("li");
        const role = document.createElement("span");
        const name = document.createElement("span");
        role.className = "staff-role";
        name.className = "staff-name";
        role.textContent = member.role.trim();
        name.textContent = member.name.trim();
        item.append(role, name);
        staffList.appendChild(item);
    });
    staffPanel.hidden = false;
}

function renderMusicUi(paused) {
    musicPaused = paused;
    musicPanel.classList.toggle("is-paused", paused);
    iconPause.hidden = paused;
    iconPlay.hidden = !paused;
    musicToggle.setAttribute("aria-label", paused ? "Geluid afspelen" : "Geluid pauzeren");
}

function setMusicPaused(paused) {
    if (paused) {
        theme.pause();
        renderMusicUi(true);
        return;
    }
    theme.play().then(() => renderMusicUi(false)).catch(() => renderMusicUi(true));
}

function setupMusic() {
    if (!Config.music || !Config.music.enabled) {
        musicPanel.hidden = true;
        return;
    }

    const initial = clamp01(Number(Config.music.volume) || 0);
    theme.src = Config.music.file;
    theme.volume = initial;
    volumeInput.value = String(Math.round(initial * 100));
    musicTitle.textContent = Config.music.title || "Eclipse Theme";

    const tryPlay = () => {
        if (!musicPaused) {
            theme.play().then(() => renderMusicUi(false)).catch(() => renderMusicUi(true));
        }
    };
    tryPlay();
    window.addEventListener("pointerdown", tryPlay, { once: true });

    musicToggle.addEventListener("click", () => setMusicPaused(!theme.paused));
    volumeInput.addEventListener("input", () => {
        theme.volume = clamp01(Number(volumeInput.value) / 100);
        if (theme.volume === 0) {
            setMusicPaused(true);
        } else if (musicPaused) {
            setMusicPaused(false);
        }
    });

    window.addEventListener("keydown", (event) => {
        if (event.code !== "Space" && event.code !== "KeyM") return;
        if (event.target && event.target.tagName === "INPUT") return;
        event.preventDefault();
        setMusicPaused(!theme.paused);
    });
}

function openDiscord() {
    const url = Config.discordUrl;
    try {
        if (typeof window.invokeNative === "function" && url) {
            window.invokeNative("openUrl", url);
        }
    } catch (error) {
        /* De invite blijft zichtbaar als de client geen browser opent. */
    }

    const label = Config.discordLabel || "";
    if (navigator.clipboard && label) {
        navigator.clipboard.writeText(label).then(() => {
            discordButton.classList.add("is-copied");
            const original = discordButton.textContent;
            discordButton.textContent = "Gekopieerd";
            window.setTimeout(() => {
                discordButton.textContent = original;
                discordButton.classList.remove("is-copied");
            }, 1400);
        }).catch(() => {});
    }
}

function onGameMessage(data) {
    if (!data || typeof data !== "object") return;

    if (data.eventName === "eclipseShutdown") {
        targetProgress = 1;
        document.body.classList.add("is-leaving");
        return;
    }

    if (data.eventName === "loadProgress" && Number.isFinite(data.loadFraction)) {
        sawLoadProgress = true;
        setProgress(data.loadFraction);
        return;
    }

    if (data.eventName === "onLogLine") {
        setLog(data.message);
        return;
    }

    if (typeof data.name === "string" && data.eventName === "initFunctionInvoking") {
        setLog(data.name);
    }

    if (sawLoadProgress) return;

    if (data.eventName === "startInitFunctionOrder" || data.eventName === "startDataFileEntries") {
        if (Number.isFinite(data.count) && data.count > 0) {
            loadStatus.dataset.count = String(data.count);
        }
    }

    if (data.eventName === "initFunctionInvoking" && Number.isFinite(data.idx)) {
        const count = Number(loadStatus.dataset.count) || 0;
        if (count > 0) setProgress(data.idx / count);
    }

    if (data.eventName === "performMapLoadFunction") {
        const count = Number(loadStatus.dataset.count) || 0;
        const current = Number(loadStatus.dataset.mapCount || 0) + 1;
        loadStatus.dataset.mapCount = String(current);
        if (count > 0) setProgress(current / count);
    }
}

function startPreview() {
    const started = performance.now();
    const duration = 14000;
    const step = (now) => {
        if (sawLoadProgress) return;
        const fraction = clamp01((now - started) / duration);
        setProgress(fraction);
        if (fraction < 1) requestAnimationFrame(step);
    };
    requestAnimationFrame(step);
}

discordButton.addEventListener("click", openDiscord);
window.addEventListener("message", (event) => onGameMessage(event.data));

renderStatic();
setupMusic();
startTips();
animateProgress();
video.play().catch(() => {});

const preview = new URLSearchParams(location.search).has("preview") || location.protocol === "file:";
if (preview) startPreview();
