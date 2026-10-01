(function (root) {
    function pad(value) {
        return String(value).padStart(2, '0');
    }

    function formatTime(hour, minute, use24) {
        hour = ((Math.floor(hour) % 24) + 24) % 24;
        minute = Math.max(0, Math.min(59, Math.floor(minute)));
        if (use24) {
            return pad(hour) + ':' + pad(minute);
        }
        var suffix = hour >= 12 ? 'PM' : 'AM';
        var hour12 = hour % 12;
        if (hour12 === 0) {
            hour12 = 12;
        }
        return hour12 + ':' + pad(minute) + ' ' + suffix;
    }

    function toMinutes(hour, minute) {
        return Math.floor(hour) * 60 + Math.floor(minute);
    }

    function fromMinutes(total) {
        var clamped = Math.max(0, Math.min(1439, Math.floor(Number(total) || 0)));
        return {
            hour: Math.floor(clamped / 60),
            minute: clamped % 60
        };
    }

    var api = {
        formatTime: formatTime,
        toMinutes: toMinutes,
        fromMinutes: fromMinutes
    };

    if (typeof module !== 'undefined' && module.exports) {
        module.exports = api;
    }

    root.SnelleTime = api;
})(typeof globalThis !== 'undefined' ? globalThis : this);
