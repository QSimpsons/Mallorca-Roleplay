(function () {
    var ICONS = {
        sun: '<circle cx="12" cy="12" r="3.2" fill="currentColor"/><g fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"><path d="M12 2.5v2.2M12 19.3v2.2M2.5 12h2.2M19.3 12h2.2M5.1 5.1l1.6 1.6M17.3 17.3l1.6 1.6M18.9 5.1l-1.6 1.6M6.7 17.3l-1.6 1.6"/></g>',
        'sun-soft': '<circle cx="12" cy="12" r="3.4" fill="currentColor"/><g fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"><path d="M12 4v2M12 18v2M4 12h2M18 12h2M6.2 6.2l1.4 1.4M16.4 16.4l1.4 1.4M17.8 6.2l-1.4 1.4M7.6 16.4l-1.4 1.4"/></g>',
        neutral: '<path d="M8 16.5h8.2a3.1 3.1 0 0 0 .2-6.2 4.2 4.2 0 0 0-8-1.1A2.8 2.8 0 0 0 8 16.5z" fill="none" stroke="currentColor" stroke-width="1.7"/>',
        smog: '<path d="M7.5 11h8a2.8 2.8 0 0 0 .2-5.6 3.6 3.6 0 0 0-6.8-.7A2.4 2.4 0 0 0 7.5 11z" fill="currentColor"/><g fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"><path d="M5 14.5h14M7 17.5h10"/></g>',
        fog: '<g fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><path d="M3 8h11M14 8h7M4 12h16M3 16h8M13 16h8"/></g>',
        overcast: '<path d="M7 16h10.5a3.5 3.5 0 0 0 .4-7 4.5 4.5 0 0 0-8.6-1.2A3.2 3.2 0 0 0 7 16z" fill="currentColor"/>',
        clouds: '<g fill="currentColor"><path d="M8 15h7.2a2.8 2.8 0 0 0 .3-5.6 3.6 3.6 0 0 0-6.9-1A2.6 2.6 0 0 0 8 15z"/><path d="M13 17h6a2.2 2.2 0 0 0 .2-4.4 2.8 2.8 0 0 0-5.2-.6"/></g>',
        clearing: '<circle cx="8" cy="9" r="2.3" fill="currentColor"/><path d="M9 17h8a3 3 0 0 0 .2-6 3.8 3.8 0 0 0-6.4-.2A2.5 2.5 0 0 0 9 17z" fill="currentColor"/>',
        rain: '<path d="M7 12h9a3 3 0 0 0 .3-6 4 4 0 0 0-7.6-1A2.7 2.7 0 0 0 7 12z" fill="currentColor"/><g stroke="currentColor" stroke-width="1.6" stroke-linecap="round"><path d="M8 15l-1 3M12 15l-1 3M16 15l-1 3"/></g>',
        thunder: '<path d="M8 11h8.2a2.8 2.8 0 0 0 .2-5.6 3.8 3.8 0 0 0-7.2-.8A2.5 2.5 0 0 0 8 11z" fill="currentColor"/><path d="M11 12l-2 4h3l-1.2 4 4-5h-2.6L11 12z" fill="currentColor"/>',
        snowlight: '<g fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"><path d="M12 4v16M5 8l14 8M19 8L5 16"/><path d="M12 8l1.2-1M12 8l-1.2-1M12 16l1.2 1M12 16l-1.2 1"/></g>',
        snow: '<g fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"><path d="M12 3v18M6 6l12 12M18 6L6 18"/><path d="M12 7.5l1.4-1.2M12 7.5l-1.4-1.2M12 16.5l1.4 1.2M12 16.5l-1.4 1.2M8 9l-1.6-.2M8 9l.2-1.6M16 15l1.6.2M16 15l-.2 1.6"/></g>',
        blizzard: '<g fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"><path d="M8 3.5v11M4.8 6.2l6.4 6.4M11.2 6.2L4.8 12.6"/><path d="M14 6h6M13 10h7M14.5 14h5M15 18h3.5"/></g>',
        xmas: '<path d="M12 4l4 6h-2.2l3 4.5h-2.4L18 19H6l3.6-4.5H7.2L10.2 10H8l4-6z" fill="currentColor"/><rect x="10.5" y="19" width="3" height="2" fill="currentColor"/>',
        halloween: '<path fill="currentColor" fill-rule="evenodd" d="M12 4.8c3.6 0 6.2 2.6 6.2 6.1 0 2.2-1 3.6-1.6 4.8-.4.8-.2 1.5.3 2.1H7.1c.5-.6.7-1.3.3-2.1C6.8 14.5 5.8 13.1 5.8 10.9c0-3.5 2.6-6.1 6.2-6.1zm-2.6 6.1c.55 0 .9.55.55 1.15l-.7 1.05h-1.15l.55-1.05c.2-.35.4-1.15.75-1.15zm4.7 0c.55 0 .9.55.55 1.15l-.7 1.05h-1.15l.55-1.05c.2-.35.4-1.15.75-1.15zM9.7 15c.65.75 1.4 1.05 2.3 1.05s1.65-.3 2.3-1.05l.75.6c-.9 1.05-1.95 1.5-3.05 1.5s-2.15-.45-3.05-1.5z"/>'
    };

    var TOGGLE_ORDER = [
        'freeze',
        'blackout',
        'instantTime',
        'dynamic',
        'h24',
        'instantWeather',
        'tsunami'
    ];

    var overlay = document.getElementById('overlay');
    var timeLabel = document.getElementById('time-label');
    var slider = document.getElementById('time-slider');
    var weatherRoot = document.getElementById('weathers');
    var toggleRoot = document.getElementById('toggles');
    var toast = document.getElementById('toast');
    var saveButton = document.getElementById('btn-save');
    var changeButton = document.getElementById('btn-change');
    var closeButton = document.getElementById('btn-close');

    var selectedWeather = 'EXTRASUNNY';
    var flags = {};
    var toastTimer = null;

    function post(name, payload) {
        if (typeof GetParentResourceName !== 'function') {
            window.__snelleActions = window.__snelleActions || [];
            window.__snelleActions.push({ name: name, payload: payload });
            return;
        }

        fetch('https://' + GetParentResourceName() + '/' + name, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(payload || {})
        }).catch(function () {});
    }

    function showToast(message) {
        if (!message) {
            return;
        }
        toast.textContent = message;
        toast.classList.add('show');
        clearTimeout(toastTimer);
        toastTimer = setTimeout(function () {
            toast.classList.remove('show');
        }, 2400);
    }

    function updateTimeLabel() {
        var parts = window.SnelleTime.fromMinutes(slider.value);
        timeLabel.textContent = window.SnelleTime.formatTime(parts.hour, parts.minute, flags.h24 === true);
        var max = Number(slider.max) || 1439;
        var fill = (Number(slider.value) / max) * 100;
        slider.style.setProperty('--fill', fill + '%');
    }

    function setFlag(key, value) {
        flags[key] = value === true;
        var button = toggleRoot.querySelector('[data-key="' + key + '"]');
        if (button) {
            button.classList.toggle('on', flags[key]);
            button.setAttribute('aria-pressed', flags[key] ? 'true' : 'false');
        }
        if (key === 'h24') {
            updateTimeLabel();
        }
    }

    function selectWeather(id) {
        selectedWeather = id;
        var buttons = weatherRoot.querySelectorAll('.weather');
        for (var i = 0; i < buttons.length; i++) {
            buttons[i].classList.toggle('is-selected', buttons[i].getAttribute('data-weather') === id);
        }
    }

    function iconSvg(name) {
        return '<svg viewBox="0 0 24 24" aria-hidden="true">' + (ICONS[name] || ICONS.sun) + '</svg>';
    }

    function renderWeathers(weathers) {
        weatherRoot.innerHTML = '';
        for (var i = 0; i < weathers.length; i++) {
            var weather = weathers[i];
            var button = document.createElement('button');
            button.type = 'button';
            button.className = 'weather';
            button.setAttribute('data-weather', weather.id);
            button.title = weather.label || weather.id;
            button.setAttribute('aria-label', weather.label || weather.id);
            button.innerHTML = iconSvg(weather.icon);
            button.addEventListener('click', function (event) {
                selectWeather(event.currentTarget.getAttribute('data-weather'));
            });
            weatherRoot.appendChild(button);
        }
    }

    function renderToggles(locale) {
        toggleRoot.innerHTML = '';
        for (var i = 0; i < TOGGLE_ORDER.length; i++) {
            var key = TOGGLE_ORDER[i];
            var row = document.createElement('div');
            row.className = 'toggle';

            var label = document.createElement('span');
            label.className = 'toggle-label';
            label.textContent = (locale && locale[key]) || key;

            var button = document.createElement('button');
            button.type = 'button';
            button.className = 'switch';
            button.setAttribute('data-key', key);
            button.setAttribute('aria-label', label.textContent);
            button.innerHTML = '<span class="knob"></span>';
            button.addEventListener('click', function (event) {
                var name = event.currentTarget.getAttribute('data-key');
                setFlag(name, !flags[name]);
            });

            row.appendChild(label);
            row.appendChild(button);
            toggleRoot.appendChild(row);
        }
    }

    function readPayload() {
        var parts = window.SnelleTime.fromMinutes(slider.value);
        return {
            hour: parts.hour,
            minute: parts.minute,
            weather: selectedWeather,
            freeze: flags.freeze === true,
            blackout: flags.blackout === true,
            dynamic: flags.dynamic === true,
            instantTime: flags.instantTime === true,
            h24: flags.h24 === true,
            instantWeather: flags.instantWeather === true,
            tsunami: flags.tsunami === true
        };
    }

    function openUI(state, weathers, locale) {
        state = state || {};
        renderWeathers(weathers || []);
        renderToggles(locale || {});

        saveButton.textContent = (locale && locale.save) || 'Save Settings';
        changeButton.textContent = (locale && locale.change) || 'Change';
        closeButton.textContent = (locale && locale.close) || 'Close';

        var hour = Number(state.hour);
        var minute = Number(state.minute);
        if (!isFinite(hour)) hour = 14;
        if (!isFinite(minute)) minute = 0;
        slider.value = String(window.SnelleTime.toMinutes(hour, minute));

        setFlag('freeze', state.freeze);
        setFlag('blackout', state.blackout);
        setFlag('dynamic', state.dynamic);
        setFlag('instantTime', state.instantTime);
        setFlag('h24', state.h24);
        setFlag('instantWeather', state.instantWeather);
        setFlag('tsunami', state.tsunami);
        selectWeather(state.weather || 'EXTRASUNNY');
        updateTimeLabel();

        overlay.classList.remove('hidden');
    }

    function closeUI() {
        overlay.classList.add('hidden');
        toast.classList.remove('show');
    }

    slider.addEventListener('input', updateTimeLabel);

    changeButton.addEventListener('click', function () {
        post('change', readPayload());
    });

    saveButton.addEventListener('click', function () {
        post('save', readPayload());
    });

    closeButton.addEventListener('click', function () {
        closeUI();
        post('close', {});
    });

    document.addEventListener('keyup', function (event) {
        if (event.key === 'Escape' && !overlay.classList.contains('hidden')) {
            closeUI();
            post('close', {});
        }
    });

    window.addEventListener('message', function (event) {
        var data = event.data;
        if (!data || !data.action) {
            return;
        }
        if (data.action === 'open') {
            openUI(data.state, data.weathers, data.locale);
        } else if (data.action === 'close') {
            closeUI();
        } else if (data.action === 'toast') {
            showToast(data.message);
        }
    });

    if (typeof GetParentResourceName !== 'function') {
        document.body.classList.add('preview');
        openUI({
            hour: 14,
            minute: 0,
            weather: 'EXTRASUNNY',
            freeze: true,
            blackout: false,
            dynamic: true,
            instantTime: true,
            h24: false,
            instantWeather: true,
            tsunami: false
        }, [
            { id: 'EXTRASUNNY', label: 'Extra Sunny', icon: 'sun' },
            { id: 'CLEAR', label: 'Clear', icon: 'sun-soft' },
            { id: 'NEUTRAL', label: 'Neutral', icon: 'neutral' },
            { id: 'SMOG', label: 'Smog', icon: 'smog' },
            { id: 'FOGGY', label: 'Foggy', icon: 'fog' },
            { id: 'OVERCAST', label: 'Overcast', icon: 'overcast' },
            { id: 'CLOUDS', label: 'Clouds', icon: 'clouds' },
            { id: 'CLEARING', label: 'Clearing', icon: 'clearing' },
            { id: 'RAIN', label: 'Rain', icon: 'rain' },
            { id: 'THUNDER', label: 'Thunder', icon: 'thunder' },
            { id: 'SNOWLIGHT', label: 'Light Snow', icon: 'snowlight' },
            { id: 'SNOW', label: 'Snow', icon: 'snow' },
            { id: 'BLIZZARD', label: 'Blizzard', icon: 'blizzard' },
            { id: 'XMAS', label: 'Christmas', icon: 'xmas' },
            { id: 'HALLOWEEN', label: 'Halloween', icon: 'halloween' }
        ], {
            freeze: 'Freeze time',
            blackout: 'Blackout',
            dynamic: 'Dynamic weather',
            instantTime: 'Instant time change',
            h24: '24 hr',
            instantWeather: 'Instant weather change',
            tsunami: 'Tsunami',
            save: 'Save Settings',
            change: 'Change',
            close: 'Close'
        });
    }
})();
