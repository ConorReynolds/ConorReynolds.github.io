import { Character } from "./character.js";
import { Script } from "./script.js";
let h1;
let characterInputEl;
let scriptNameInput;
let scriptAuthorInput;
let title = "BotC Script Tool";
async function readFileDialog() {
  const input = document.createElement("input");
  input.type = "file";
  let file;
  input.addEventListener("change", (event) => {
    file = event.target.files[0];
    // setting up the reader
    const reader = new FileReader();
    reader.readAsText(file, "UTF-8");
    reader.onload = (readerEvent) => {
      const content = readerEvent.target.result; // this is the content!
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
async function writeDialogJSON(filename, contents) {
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
let script;
function renderScript() {
  h1.innerHTML = `${script.name}<span>by ${script.author}</span>`;
  document.querySelector("#script").innerHTML = script.render();
  // Add listeners to all icons
  document.querySelectorAll("img.icon").forEach((element) => {
    element.addEventListener("click", (event) => {
      event.preventDefault();
      script.remove(element.id);
      renderScript();
    }, { once: true });
  });
}
function reinitStorage() {
  localStorage.clear();
  // set defaults
  localStorage.setItem("app-name", "BotC Script Tool");
  localStorage.setItem("app-version", "0.0.1");
}
window.addEventListener("DOMContentLoaded", () => {
  if (localStorage.length === 0) {
    reinitStorage();
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
  document.getElementById("script-name-form").addEventListener(
    "input",
    (event) => {
      event.preventDefault();
      script.name = scriptNameInput.value;
      localStorage.setItem("script", script.toJSON());
    },
  );
  document.getElementById("script-author-form").addEventListener(
    "input",
    (event) => {
      event.preventDefault();
      script.author = scriptAuthorInput.value;
      localStorage.setItem("script", script.toJSON());
    },
  );
  renderScript();
  document.querySelector("#character-form").addEventListener(
    "submit",
    (event) => {
      event.preventDefault();
      const input = characterInputEl.value.toLowerCase();
      const result = Character.fuzzyMatch(input);
      const match = result.match;
      // const elements: string[] = result.rawHTML;
      try {
        script.add(match);
        script.sort();
        renderScript();
        document.querySelector("#current-matches").innerHTML = "";
        localStorage.setItem("script", script.toJSON());
      } catch (e) {
        console.error(e);
        return;
      }
      characterInputEl.value = "";
    },
  );
  document.querySelector("#character-form").addEventListener(
    "input",
    (_event) => {
      const input = characterInputEl.value.toLowerCase();
      const result = Character.fuzzyMatch(input);
      const res = result.result;
      let html = "";
      for (let i = 0; i < res.length; i++) {
        html +=
          `<div><img class="thumbnail" src="/botc-script-tool/src/assets/unofficial-icons/Icon_${
            res[i][0]
          }.png"/>` +
          res[i][1] + `</div>`;
      }
      document.querySelector("#current-matches").innerHTML = html;
    },
  );
  document.querySelector("#import-form").addEventListener("submit", (event) => {
    event.preventDefault();
    readFileDialog();
  });
  document.querySelector("#export-form").addEventListener("submit", (event) => {
    // Import and export should be either to clipboard or to localStorage on
    // iOS or Android.
    event.preventDefault();
    writeDialogJSON(script.name, script.toJSON());
  });
  document.querySelector("#clear-form").addEventListener("submit", (event) => {
    event.preventDefault();
    script.clear();
    scriptNameInput.value = "";
    scriptAuthorInput.value = "";
    renderScript();
  });
  document.querySelector("#print-form").addEventListener("submit", (event) => {
    event.preventDefault();
    document.title = script.name;
    h1.innerHTML = `${script.name}<span>by ${script.author}</span>`;
    window.print();
  });
  window.addEventListener("afterprint", (_event) => {
    document.title = title;
  });
});
window.addEventListener("unload", (_event) => {
  localStorage.setItem("script", script.toJSON());
});
