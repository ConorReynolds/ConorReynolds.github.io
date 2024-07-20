import { Character } from "./character.js";
import { Script } from "./script.js";

let h1;
let characterInputEl;
let scriptNameInput;
let scriptAuthorInput;

const appName = "Unofficial BotC Script Tool";
const appVersion = "0.0.1";

function readFileDialog() {
  const input = document.createElement("input");
  input.type = "file";

  let file;
  input.addEventListener("change", function (event) {
    file = event.target.files[0];
    const reader = new FileReader();
    reader.readAsText(file, "UTF-8");
    reader.onload = function (readerEvent) {
      const content = readerEvent.target.result;
      if (typeof content === "string") {
        script.loadFromJSON(JSON.parse(content));
        renderScript();
        scriptNameInput.value = script.name;
        scriptAuthorInput.value = script.author;
      }
    };
  });
  input.click();
}

function writeDialogJSON(filename, contents) {
  const anchor = document.createElement("a");
  anchor.setAttribute(
    "href",
    "data:application/json;charset=utf-8," + encodeURIComponent(contents),
  );
  anchor.setAttribute("download", `${filename}.json`);
  document.body.appendChild(anchor);
  anchor.click();
  document.body.removeChild(anchor);
}

// https://stackoverflow.com/a/8265310
function preloadImages(srcs) {
  function loadImage(src) {
    return new Promise(function (resolve, reject) {
      const img = new Image();
      img.onload = function () {
        resolve(img);
      };
      img.onerror = img.onabort = function () {
        reject(src);
      };
      img.src = src;
    });
  }

  const promises = [];
  for (let i = 0; i < srcs.length; i++) {
    promises.push(loadImage(srcs[i]));
  }

  return Promise.all(promises);
}

const thumbnails = [];
for (const charObj of Character.flat.filter((c) => c["team"] !== "traveler")) {
  thumbnails.push(
    `src/assets/custom-icons/TinyIcon_${charObj.id}.webp`,
  );
}

preloadImages(thumbnails).then((_) => {
  console.log(`preloaded ${thumbnails.length} thumbnails`);
});

let script;

function renderScript() {
  h1.innerHTML = `${script.name}<span>by ${script.author}</span>`;
  document.querySelector("#script").innerHTML = script.render();
  if (localStorage.getItem("compact-night-sheet") === "true") {
    document.querySelector(".night-sheet").classList.add("compact");
  }
  // Add listeners to all icons
  document.querySelectorAll(".script img.icon").forEach(function (element) {
    element.addEventListener("click", function (event) {
      event.preventDefault();
      script.remove(element.parentElement.id);
      renderScript();
    }, { once: true });
  });

  globalThis.dispatchEvent(new Event("scriptrendered"));
}

function initStorage() {
  localStorage.clear();

  // set defaults
  localStorage.setItem("app-name", appName);
  localStorage.setItem("app-version", appVersion);
}

// Minor/Major version changes involve the first two version numbers.
// They generally add features and we should show the changelog.
function _atLeastMinorVersionChange() {
  const oldAppVersion = localStorage.getItem("app-version")
    .split(".")
    .map(parseInt);
  const currentVersion = appVersion.split(".").map(parseInt);

  const majorChange = currentVersion[0] > oldAppVersion[0];
  const minorChange = currentVersion[1] > oldAppVersion[1];

  return majorChange || minorChange;
}

globalThis.addEventListener("DOMContentLoaded", () => {
  if (localStorage.length === 0) {
    initStorage();
  }

  h1 = document.querySelector("h1");
  characterInputEl = document.querySelector("#character-input");
  scriptNameInput = document.querySelector("#script-name-input");
  scriptAuthorInput = document.querySelector("#script-author-input");

  script = new Script();

  if (localStorage.getItem("script")) {
    script.loadFromJSON(JSON.parse(localStorage.getItem("script")));
    scriptNameInput.value = script.name;
    scriptAuthorInput.value = script.author;
  }

  renderScript();

  if (localStorage.getItem("compact-night-sheet")) {
    const b = localStorage.getItem("compact-night-sheet");
    const checkbox = document.querySelector("#compact-night-sheet-checkbox");

    if (b === "true") {
      checkbox.checked = true;
      document.querySelector(".night-sheet").classList.add("compact");
    }
    if (b === "false") {
      checkbox.checked = false;
    }
  }

  document.getElementById("script-name-form").addEventListener(
    "input",
    function (event) {
      event.preventDefault();
      script.name = scriptNameInput.value;
      localStorage.setItem("script", script.toJSON());
    },
  );

  document.getElementById("script-author-form").addEventListener(
    "input",
    function (event) {
      event.preventDefault();
      script.author = scriptAuthorInput.value;
      localStorage.setItem("script", script.toJSON());
    },
  );

  document.getElementById("script-name-form").addEventListener(
    "submit",
    function (event) {
      event.preventDefault();
    },
  );

  document.getElementById("script-author-form").addEventListener(
    "submit",
    function (event) {
      event.preventDefault();
    },
  );

  document.querySelector("#character-form").addEventListener(
    "submit",
    function (event) {
      event.preventDefault();
      const input = characterInputEl.value.toLowerCase();
      const result = Character.fuzzyMatch(input);
      const match = result.match;

      try {
        script.add(match);
        script.sort();
        renderScript();

        document.querySelector("#current-matches").innerHTML = "";
        localStorage.setItem("script", script.toJSON());
        characterInputEl.value = "";
      } catch (e) {
        console.error(e);
      }
    },
  );

  document.querySelector("#character-form").addEventListener(
    "input",
    function (_event) {
      const input = characterInputEl.value.toLowerCase();
      const result = Character.fuzzyMatch(input);
      const res = result.result;
      let html = "";
      for (let i = 0; i < res.length; i++) {
        const char = new Character(res[i][0].id);
        html +=
          `<div class="match"><img class="thumbnail" src="${char.tinyIcon}"/>` +
          (result.key === "name" ? res[i][1] : char.name) + `</div>`;
      }
      document.querySelector("#current-matches").innerHTML = html;

      function addToScript(i) {
        script.add(new Character(res[i][0].id));
        script.sort();
        renderScript();

        document.querySelector("#current-matches").innerHTML = "";
        localStorage.setItem("script", script.toJSON());
        characterInputEl.value = "";
      }

      // Register click/Enter keypress event for matches to add the character
      document.querySelectorAll("#current-matches .match").forEach(
        function (element, i) {
          element.tabIndex = 0;
          element.addEventListener("click", function (event) {
            event.preventDefault();
            addToScript(i);
          });

          element.addEventListener("keydown", function (event) {
            if (event.key === "Enter") {
              addToScript(i);
            }
          });
        },
      );
    },
  );

  document.querySelector("#import-form").addEventListener(
    "submit",
    function (event) {
      event.preventDefault();
      readFileDialog();
    },
  );

  document.querySelector("#export-form").addEventListener(
    "submit",
    function (event) {
      event.preventDefault();
      writeDialogJSON(script.name, script.toJSON());
    },
  );

  document.querySelector("#clear-form").addEventListener(
    "submit",
    function (event) {
      event.preventDefault();
      script.clear();
      Character.clearCustoms();
      scriptNameInput.value = "";
      scriptAuthorInput.value = "";
      renderScript();
    },
  );

  document.querySelector("#print-form").addEventListener(
    "submit",
    function (event) {
      event.preventDefault();
      document.title = script.name;
      h1.innerHTML = `${script.name}<span>by ${script.author}</span>`;
      globalThis.print();
    },
  );

  document.querySelector("#compact-night-sheet-form").addEventListener(
    "change",
    function (event) {
      event.preventDefault();
      if (event.target.checked === true) {
        document.querySelector(".night-sheet").classList.add("compact");
        localStorage.setItem("compact-night-sheet", "true");
      } else {
        document.querySelector(".night-sheet").classList.remove("compact");
        localStorage.setItem("compact-night-sheet", "false");
      }
    },
  );

  globalThis.addEventListener("afterprint", function (_event) {
    document.title = appName;
  });

  globalThis.addEventListener("unload", function (_event) {
    localStorage.setItem("script", script.toJSON());
  });

  const sidebar = document.querySelector("#sidebar");
  const sidebarToggleButton = document.querySelector("#open-sidebar-button");

  sidebarToggleButton.addEventListener("click", (event) => {
    event.preventDefault();
    sidebar.classList.toggle("expanded");
  });

  const allchars = document.querySelector("#all-characters");
  const filterInputForm = document.querySelector("#filter-input-form");
  const filterInputElem = document.querySelector("#filter-input");

  function renderSidebarChars(predicate) {
    allchars.innerHTML = "";
    predicate = predicate ?? ((c) => c);

    const charlist = Character.flat
      .concat(Character.customFlat)
      .filter((o) => o.team !== "traveler")
      .filter(predicate)
      .toSorted((o1, o2) => o1.name > o2.name);

    const strFilter = filterInputElem.value;
    const filteredChars = fuzzysort.go(
      strFilter,
      charlist,
      { key: "name", all: true },
    );

    for (const result of filteredChars) {
      // console.log(obj);
      const character = new Character(result.obj.id);
      const selected = script.contains(character) ? "selected" : "";
      let html =
        `<div class="item ${selected}" data-id="${character.id}" data-team="${character.team}">`;
      html += `<img class="icon" src="${character.icon}"/>`;
      html += `<div>${result.highlight("<b>", "</b>")}</div>`;
      html += `</div>`;

      const elem = document.createElement("div");
      elem.innerHTML = html;

      elem.firstChild.addEventListener("click", (event) => {
        event.preventDefault();
        if (script.contains(character)) {
          script.remove(character.id);
        } else {
          script.add(character);
          script.sort();
        }
        renderScript();
      });

      allchars.appendChild(elem.firstChild);
    }
  }

  renderSidebarChars();

  const townsfolkForm = document.querySelector("#townsfolk-form");
  const outsiderForm = document.querySelector("#outsider-form");
  const minionForm = document.querySelector("#minion-form");
  const demonForm = document.querySelector("#demon-form");

  function updateSidebar() {
    const townsfolk = document.querySelector("#townsfolk-checkbox");
    const outsider = document.querySelector("#outsider-checkbox");
    const minion = document.querySelector("#minion-checkbox");
    const demon = document.querySelector("#demon-checkbox");

    function predicate(character) {
      if (character.team === "townsfolk" && !townsfolk.checked) {
        return false;
      }
      if (character.team === "outsider" && !outsider.checked) {
        return false;
      }
      if (character.team === "minion" && !minion.checked) {
        return false;
      }
      if (character.team === "demon" && !demon.checked) {
        return false;
      }
      return true;
    }

    renderSidebarChars(predicate);
  }

  globalThis.addEventListener("scriptrendered", (_) => {
    updateSidebar();
  });

  [townsfolkForm, outsiderForm, minionForm, demonForm].forEach((x) =>
    x.addEventListener("change", (_) => {
      updateSidebar();
    })
  );

  filterInputForm.addEventListener("input", function (event) {
    event.preventDefault();
    updateSidebar();
  });

  filterInputForm.addEventListener("submit", function (event) {
    event.preventDefault();
    if (allchars.firstChild) {
      const charid = allchars.firstChild.getAttribute("data-id");
      const character = new Character(charid);

      if (script.contains(character)) {
        script.remove(character.id);
      } else {
        script.add(character);
        script.sort();
      }
      renderScript();
    }
  });
});
