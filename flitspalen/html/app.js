const root = document.getElementById('flits');
const naamEl = document.getElementById('naam');
const snelheidEl = document.getElementById('snelheid');
const redenEl = document.getElementById('reden');
const boeteEl = document.getElementById('boete');
const statusEl = document.getElementById('status');

let verbergTimer = 0;

function redenTekst(data) {
    const teHard = typeof data.limiet === 'number' && data.snelheid > data.limiet;
    if (data.doorRood && teHard) {
        return 'Door rood en te hard';
    }
    if (data.doorRood) {
        return 'Door rood gereden';
    }
    return 'Te hard';
}

function vul(data) {
    naamEl.textContent = data.naam || 'Flitspaal';
    if (typeof data.limiet === 'number') {
        snelheidEl.textContent = data.snelheid + ' km/h · limiet ' + data.limiet;
    } else {
        snelheidEl.textContent = data.snelheid + ' km/h';
    }
    redenEl.textContent = redenTekst(data);
    boeteEl.textContent = 'Boete €' + (data.bedrag || 0);
    statusEl.textContent = data.afgeschreven
        ? 'Afgeschreven van je rekening'
        : 'Proces-verbaal';
}

function toon(data) {
    vul(data);
    root.hidden = false;
    root.classList.remove('actief');
    void root.offsetWidth;
    root.classList.add('actief');
    window.clearTimeout(verbergTimer);
    verbergTimer = window.setTimeout(function () {
        root.classList.remove('actief');
        root.hidden = true;
    }, 3700);
}

window.addEventListener('message', function (event) {
    const bericht = event.data || {};
    if (!bericht.data) {
        return;
    }
    if (bericht.action === 'flits') {
        toon(bericht.data);
    } else if (bericht.action === 'bijwerken' && !root.hidden) {
        vul(bericht.data);
    }
});

if (location.protocol === 'file:') {
    window.setTimeout(function () {
        toon({
            naam: 'Kruispunt Mission Row',
            limiet: 50,
            snelheid: 78,
            doorRood: true,
            bedrag: 716,
            afgeschreven: false
        });
    }, 300);
}
