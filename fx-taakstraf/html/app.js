let progressInterval = null

window.addEventListener("message", function (event) {
    const data = event.data

    const box         = document.getElementById("box")
    const progressWrap = document.getElementById("progress-wrap")
    const bar         = document.getElementById("progress-bar")
    const pct         = document.getElementById("progress-pct")
    const leftEl      = document.getElementById("left")

    if (data.action === "open") {
        box.style.display = "block"

        leftEl.innerText = data.left
        document.getElementById("by").innerText     = data.by
        document.getElementById("reason").innerText = data.reason

        progressWrap.style.display = "none"
        bar.style.width = "0%"
        if (pct) pct.innerText = "0%"
    }

    if (data.action === "update") {
        const prev = leftEl.innerText
        leftEl.innerText = data.left

        // Bounce animation on change
        if (prev !== String(data.left)) {
            leftEl.classList.remove("bounce")
            void leftEl.offsetWidth // reflow
            leftEl.classList.add("bounce")
        }
    }

    if (data.action === "forceProgress") {
        progressWrap.style.display = "block"
        bar.style.width = "0%"
        if (pct) pct.innerText = "0%"

        let start    = Date.now()
        let duration = data.time

        clearInterval(progressInterval)
        progressInterval = setInterval(() => {
            let percent = ((Date.now() - start) / duration) * 100
            let clamped = Math.min(percent, 100)
            bar.style.width = clamped + "%"
            if (pct) pct.innerText = Math.floor(clamped) + "%"
        }, 16)
    }

    if (data.action === "forceProgressEnd") {
        clearInterval(progressInterval)
        bar.style.width = "0%"
        if (pct) pct.innerText = "0%"
        progressWrap.style.display = "none"
    }

    if (data.action === "close") {
        box.style.display = "none"
        progressWrap.style.display = "none"
        bar.style.width = "0%"
        if (pct) pct.innerText = "0%"
    }
})