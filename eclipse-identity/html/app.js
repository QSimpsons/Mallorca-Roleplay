const preview = new URLSearchParams(location.search).get("preview") === "1";

const state = {
  serverName: "ECLIPSE RP",
  discord: "https://discord.gg/eclipserp",
  rules: "https://discord.gg/eclipserp",
  dateFormat: "DD/MM/YYYY",
  minHeight: 120,
  maxHeight: 220,
  minAge: 18,
  maxAge: 100,
  minName: 2,
  maxName: 16,
  sex: null,
  pending: false,
};

const app = document.getElementById("app");
const layout = document.getElementById("layout");
const form = document.getElementById("form");
const success = document.getElementById("success");
const submitButton = document.getElementById("submit");
const firstname = document.getElementById("firstname");
const lastname = document.getElementById("lastname");
const day = document.getElementById("day");
const month = document.getElementById("month");
const year = document.getElementById("year");
const height = document.getElementById("height");
const rules = document.getElementById("rules");
const sexRow = document.getElementById("sex-row");
const formError = document.getElementById("form-error");

if (preview) {
  document.documentElement.classList.add("is-preview");
  document.getElementById("preview-reset").hidden = false;
}

function resourceName() {
  if (typeof GetParentResourceName === "function") {
    return GetParentResourceName();
  }
  return "eclipse-identity";
}

function openUrl(url) {
  if (!url) return;
  if (typeof window.invokeNative === "function") {
    window.invokeNative("openUrl", url);
    return;
  }
  window.open(url, "_blank", "noopener");
}

function applyConfig(data) {
  if (!data) return;
  ["serverName", "discord", "rules", "dateFormat"].forEach((key) => {
    if (typeof data[key] === "string" && data[key] !== "") state[key] = data[key];
  });
  ["minHeight", "maxHeight", "minAge", "maxAge", "minName", "maxName"].forEach((key) => {
    const value = Number(data[key]);
    if (Number.isFinite(value)) state[key] = value;
  });

  document.querySelectorAll(".brand-name").forEach((node) => {
    node.textContent = state.serverName;
  });
  firstname.maxLength = state.maxName;
  lastname.maxLength = state.maxName;
  document.getElementById("discord-link").href = state.discord;
  document.getElementById("rules-link").href = state.rules;
  document.title = state.serverName + " — Burgerregistratie";
}

function show() {
  app.classList.add("is-open");
  app.setAttribute("aria-hidden", "false");
}

function hide() {
  app.classList.remove("is-open");
  app.setAttribute("aria-hidden", "true");
}

function shake() {
  layout.classList.remove("is-shake");
  void layout.offsetWidth;
  layout.classList.add("is-shake");
}

function setFieldError(name, message) {
  const error = document.getElementById("err-" + name);
  const field = document.getElementById("field-" + name);
  if (error) error.textContent = message || "";
  if (field) field.classList.toggle("is-invalid", Boolean(message));
  if (name === "sex") sexRow.classList.toggle("is-invalid", Boolean(message));
  if (name === "rules") document.getElementById("agree").classList.toggle("is-invalid", Boolean(message));
}

function clearErrors() {
  ["firstname", "lastname", "dob", "height", "sex", "rules"].forEach((name) => setFieldError(name, ""));
  formError.textContent = "";
}

function setFormError(message) {
  formError.textContent = message || "";
  if (message) shake();
}

function setLoading(loading) {
  state.pending = loading;
  submitButton.classList.toggle("is-loading", loading);
  submitButton.disabled = loading;
  submitButton.setAttribute("aria-busy", loading ? "true" : "false");
}

function titleCaseName(value) {
  return value
    .trim()
    .replace(/\s+/g, " ")
    .split(" ")
    .map((part) =>
      part
        .split("-")
        .map((piece) =>
          piece
            .split("'")
            .map((bit) => {
              if (!bit) return bit;
              return bit.charAt(0).toLocaleUpperCase("nl") + bit.slice(1).toLocaleLowerCase("nl");
            })
            .join("'")
        )
        .join("-")
    )
    .join(" ");
}

let namePattern;
try {
  namePattern = new RegExp("^[\\p{L}][\\p{L}\\s.'-]*$", "u");
} catch (error) {
  namePattern = /^[A-Za-zÀ-ÿ][A-Za-zÀ-ÿ\s.'-]*$/;
}

function validName(value) {
  if (value.length < state.minName || value.length > state.maxName) return false;
  if (!namePattern.test(value)) return false;
  if (/^[\s.'-]|[\s.'-]$/.test(value)) return false;
  if (/[\s.'-]{2,}/.test(value)) return false;
  return true;
}

function daysInMonth(year, monthNumber) {
  return new Date(year, monthNumber, 0).getDate();
}

function ageOf(year, monthNumber, dayNumber) {
  const today = new Date();
  let age = today.getFullYear() - year;
  const monthNow = today.getMonth() + 1;
  const dayNow = today.getDate();
  if (monthNow < monthNumber || (monthNow === monthNumber && dayNow < dayNumber)) age -= 1;
  return age;
}

function formatDob(dayNumber, monthNumber, yearNumber) {
  const dd = String(dayNumber).padStart(2, "0");
  const mm = String(monthNumber).padStart(2, "0");
  const yyyy = String(yearNumber);
  if (state.dateFormat === "MM/DD/YYYY") return mm + "/" + dd + "/" + yyyy;
  if (state.dateFormat === "DD-MM-YYYY") return dd + "-" + mm + "-" + yyyy;
  if (state.dateFormat === "YYYY-MM-DD") return yyyy + "-" + mm + "-" + dd;
  return dd + "/" + mm + "/" + yyyy;
}

function readForm() {
  clearErrors();
  const errors = [];
  const first = titleCaseName(firstname.value);
  const last = titleCaseName(lastname.value);

  if (!first) {
    setFieldError("firstname", "Vul je voornaam in.");
    errors.push("firstname");
  } else if (!validName(first)) {
    const message = first.length < state.minName || first.length > state.maxName
      ? "Voornaam moet " + state.minName + " tot " + state.maxName + " tekens zijn."
      : "Voornaam mag alleen letters bevatten.";
    setFieldError("firstname", message);
    errors.push("firstname");
  } else {
    firstname.value = first;
  }

  if (!last) {
    setFieldError("lastname", "Vul je achternaam in.");
    errors.push("lastname");
  } else if (!validName(last)) {
    const message = last.length < state.minName || last.length > state.maxName
      ? "Achternaam moet " + state.minName + " tot " + state.maxName + " tekens zijn."
      : "Achternaam mag alleen letters bevatten.";
    setFieldError("lastname", message);
    errors.push("lastname");
  } else {
    lastname.value = last;
  }

  const dayNumber = Number(day.value);
  const monthNumber = Number(month.value);
  const yearNumber = Number(year.value);
  const complete = day.value.length > 0 && month.value.length > 0 && year.value.length === 4;
  const realDate =
    complete &&
    monthNumber >= 1 &&
    monthNumber <= 12 &&
    dayNumber >= 1 &&
    dayNumber <= daysInMonth(yearNumber, monthNumber);

  let dob = "";
  if (!realDate) {
    setFieldError("dob", "Vul een geldige geboortedatum in (DD/MM/JJJJ).");
    errors.push("dob");
  } else {
    const age = ageOf(yearNumber, monthNumber, dayNumber);
    if (age < state.minAge) {
      setFieldError("dob", "Je moet minimaal " + state.minAge + " jaar zijn.");
      errors.push("dob");
    } else if (age > state.maxAge) {
      setFieldError("dob", "De maximale leeftijd is " + state.maxAge + " jaar.");
      errors.push("dob");
    } else {
      dob = formatDob(dayNumber, monthNumber, yearNumber);
    }
  }

  const heightNumber = Number(height.value);
  if (!height.value || !Number.isInteger(heightNumber) || heightNumber < state.minHeight || heightNumber > state.maxHeight) {
    setFieldError("height", "Lengte moet tussen " + state.minHeight + " en " + state.maxHeight + " cm zijn.");
    errors.push("height");
  }

  if (state.sex !== "m" && state.sex !== "f") {
    setFieldError("sex", "Kies een geslacht.");
    errors.push("sex");
  }

  if (!rules.checked) {
    setFieldError("rules", "Je moet de regels accepteren.");
    errors.push("rules");
  }

  if (errors.length) {
    const focusTarget = {
      firstname: firstname,
      lastname: lastname,
      dob: day,
      height: height,
      sex: sexRow.querySelector(".sex"),
      rules: rules,
    }[errors[0]];
    if (focusTarget && typeof focusTarget.focus === "function") focusTarget.focus();
    shake();
    return null;
  }

  return {
    firstname: first,
    lastname: last,
    dateofbirth: dob,
    sex: state.sex,
    height: heightNumber,
    rules: true,
  };
}

function selectSex(value) {
  state.sex = value;
  sexRow.querySelectorAll(".sex").forEach((button) => {
    const selected = button.dataset.sex === value;
    button.classList.toggle("is-selected", selected);
    button.setAttribute("aria-pressed", selected ? "true" : "false");
  });
  setFieldError("sex", "");
}

function showSuccess(name) {
  document.getElementById("success-name").textContent = name;
  form.hidden = true;
  success.hidden = false;
}

function resetForm() {
  form.reset();
  state.sex = null;
  sexRow.querySelectorAll(".sex").forEach((button) => {
    button.classList.remove("is-selected");
    button.setAttribute("aria-pressed", "false");
  });
  clearErrors();
  success.hidden = true;
  form.hidden = false;
  firstname.focus();
}

async function submitToGame(payload) {
  const response = await fetch("https://" + resourceName() + "/register", {
    method: "POST",
    headers: { "Content-Type": "application/json; charset=UTF-8" },
    body: JSON.stringify(payload),
  });
  const text = await response.text();
  if (!text) return { ok: false, error: "Geen antwoord van de server." };
  try {
    return JSON.parse(text);
  } catch (error) {
    return { ok: false, error: "Registreren is mislukt." };
  }
}

sexRow.addEventListener("click", (event) => {
  const button = event.target.closest(".sex");
  if (!button) return;
  selectSex(button.dataset.sex);
});

function onlyDigits(input, max) {
  input.value = input.value.replace(/\D/g, "").slice(0, max);
}

day.addEventListener("input", () => {
  onlyDigits(day, 2);
  if (day.value.length === 2) month.focus();
});

month.addEventListener("input", () => {
  onlyDigits(month, 2);
  if (month.value.length === 2) year.focus();
});

year.addEventListener("input", () => onlyDigits(year, 4));
height.addEventListener("input", () => onlyDigits(height, 3));

month.addEventListener("keydown", (event) => {
  if (event.key === "Backspace" && month.value === "") day.focus();
});

year.addEventListener("keydown", (event) => {
  if (event.key === "Backspace" && year.value === "") month.focus();
});

day.addEventListener("paste", (event) => {
  const text = (event.clipboardData.getData("text") || "").trim();
  const match = text.match(/^(\d{1,2})\D(\d{1,2})\D(\d{4})$/) || text.match(/^(\d{2})(\d{2})(\d{4})$/);
  if (!match) return;
  event.preventDefault();
  day.value = match[1].padStart(2, "0");
  month.value = match[2].padStart(2, "0");
  year.value = match[3];
  year.focus();
});

["firstname", "lastname", "height"].forEach((id) => {
  document.getElementById(id).addEventListener("input", () => setFieldError(id === "height" ? "height" : id, ""));
});

[day, month, year].forEach((input) => {
  input.addEventListener("input", () => setFieldError("dob", ""));
});

rules.addEventListener("change", () => setFieldError("rules", ""));

document.getElementById("rules-link").addEventListener("mousedown", (event) => {
  event.preventDefault();
  event.stopPropagation();
});

document.getElementById("rules-link").addEventListener("click", (event) => {
  event.preventDefault();
  event.stopPropagation();
  openUrl(state.rules);
});

document.getElementById("discord-link").addEventListener("click", (event) => {
  event.preventDefault();
  openUrl(state.discord);
});

form.addEventListener("submit", async (event) => {
  event.preventDefault();
  if (state.pending) return;

  const payload = readForm();
  if (!payload) return;

  setLoading(true);
  try {
    if (preview) {
      await new Promise((resolve) => setTimeout(resolve, 450));
      showSuccess(payload.firstname + " " + payload.lastname);
      return;
    }

    const result = await submitToGame(payload);
    if (!result || result.ok !== true) {
      setFormError((result && result.error) || "Registreren is mislukt.");
      return;
    }

    showSuccess(payload.firstname + " " + payload.lastname);
  } catch (error) {
    setFormError("Geen verbinding met het spel. Probeer het opnieuw.");
  } finally {
    setLoading(false);
  }
});

document.getElementById("preview-reset").addEventListener("click", resetForm);

window.addEventListener("keydown", (event) => {
  if (!app.classList.contains("is-open") || event.key !== "Escape") return;
  event.preventDefault();
  setFormError("Rond eerst je registratie af.");
});

window.addEventListener("message", (event) => {
  const data = event.data || {};
  if (data.action === "open" || (data.type === "enableui" && data.enable)) {
    applyConfig(data);
    show();
  }
  if (data.action === "close" || (data.type === "enableui" && data.enable === false)) {
    hide();
  }
});

applyConfig({});

if (preview) show();
