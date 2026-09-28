(function () {
  const progressEl = document.getElementById("progress");
  const percentEl = document.getElementById("percent");
  const statusEl = document.getElementById("status");
  const bar = document.getElementById("progressbar");

  const labels = {
    INIT_BEFORE_MAP_LOADED: "Kaart voorbereiden…",
    MAP: "Wereld laden…",
    INIT_AFTER_MAP_LOADED: "Resources starten…",
    INIT_SESSION: "Sessie opzetten…",
  };

  function setProgress(value) {
    const pct = Math.max(0, Math.min(100, Math.floor(value)));
    progressEl.style.width = pct + "%";
    percentEl.textContent = pct + "%";
    bar.setAttribute("aria-valuenow", String(pct));
  }

  function setStatus(text) {
    if (text) statusEl.textContent = text;
  }

  window.addEventListener("message", (event) => {
    const data = event.data;
    if (!data) return;

    if (data.eventName === "loadProgress" || typeof data.loadFraction === "number") {
      const fraction = typeof data.loadFraction === "number" ? data.loadFraction : data.progress || 0;
      setProgress(fraction * 100);
    }

    if (data.eventName === "onLogLine" && data.message) {
      setStatus(data.message);
    }

    if (data.type === "loadingScreen" && data.message) {
      setStatus(data.message);
    }
  });

  // Fallback animation when opened outside FiveM (preview in browser)
  if (!window.invokeNative) {
    let n = 0;
    const keys = Object.keys(labels);
    const timer = setInterval(() => {
      n += 1.4;
      setProgress(n);
      setStatus(labels[keys[Math.min(keys.length - 1, Math.floor(n / 25))]]);
      if (n >= 100) clearInterval(timer);
    }, 80);
  }
})();
