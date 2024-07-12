import { Character } from "./character.js";
// Need a full list of characters that can be added.
export class Script {
  author;
  name;
  townsfolk;
  outsiders;
  minions;
  demons;

  constructor() {
    this.townsfolk = [];
    this.outsiders = [];
    this.minions = [];
    this.demons = [];
    this.name = "";
    this.author = "";
  }

  clear() {
    this.townsfolk = [];
    this.outsiders = [];
    this.minions = [];
    this.demons = [];
  }

  loadFromJSON(obj) {
    // This function needs to be generalised to accomodate completely custom
    // characters. Just replacing icons is fine but really all parts of the
    // character object should be overwritable.
    if (!Array.isArray(obj)) {
      console.error(obj);
      throw Error("Invalid JSON – can’t parse script.");
    }
    this.clear();
    for (const item of obj) {
      if (typeof item === "object" && item["id"] === "_meta") {
        console.log(item);
        this.name = item["name"] ? item["name"] : "";
        this.author = item["author"] ? item["author"] : "";
      }
      if (typeof item === "object" && item["id"] !== "_meta") {
        try {
          const char = new Character(item["id"]);
          if (item["image"]) {
            char.iconSrc = item["image"];
          }
          this.add(char);
        } catch (e) {
          console.error(e);
        }
      }
      if (typeof item === "string") {
        try {
          this.add(new Character(item));
        } catch (e) {
          console.error(e);
        }
      }
    }
    this.sort();
  }

  static asType(n) {
    switch (n) {
      case 0:
        return "Townsfolk";
      case 1:
        return "Outsider";
      case 2:
        return "Minion";
      case 3:
        return "Demon";
    }
  }

  remove(cid) {
    console.log("called");
    const char = new Character(cid);
    if (char.type === "Townsfolk") {
      const idx = this.townsfolk.findIndex((c) => c.id === char.id);
      this.townsfolk.splice(idx, 1);
    }
    if (char.type === "Outsider") {
      const idx = this.outsiders.findIndex((c) => c.id === char.id);
      this.outsiders.splice(idx, 1);
    }
    if (char.type === "Minion") {
      const idx = this.minions.findIndex((c) => c.id === char.id);
      this.minions.splice(idx, 1);
    }
    if (char.type === "Demon") {
      const idx = this.demons.findIndex((c) => c.id === char.id);
      this.demons.splice(idx, 1);
    }
  }

  add(c) {
    switch (c.type) {
      case "Townsfolk":
        if (this.townsfolk.some((c0) => c.id === c0.id)) {
          return;
        }
        this.townsfolk.push(c);
        return;
      case "Outsider":
        if (this.outsiders.some((c0) => c.id === c0.id)) {
          return;
        }
        this.outsiders.push(c);
        return;
      case "Minion":
        if (this.minions.some((c0) => c.id === c0.id)) {
          return;
        }
        this.minions.push(c);
        return;
      case "Demon":
        if (this.demons.some((c0) => c.id === c0.id)) {
          return;
        }
        this.demons.push(c);
        return;
    }
  }

  sort() {
    this.townsfolk.sort(Character.compare);
    this.outsiders.sort(Character.compare);
    this.minions.sort(Character.compare);
    this.demons.sort(Character.compare);
  }

  render() {
    let str = `<div class="script" id="${this.name}">`;
    for (
      const [i, a] of [
        this.townsfolk,
        this.outsiders,
        this.minions,
        this.demons,
      ]
        .entries()
    ) {
      const plural = Script.asType(i) === "Townsfolk"
        ? Script.asType(i)
        : Script.asType(i) + "s";
      str += `<h3><span>${plural?.toUpperCase()}</span></h3>`;
      str += `<div nitems="${a.length}" class="${
        Script.asType(i)?.toLowerCase()
      }">`;
      for (const c of a) {
        str += `<div class="item">`;
        if (c.iconSrc) {
          str +=
            `<img id=${c.id} class="icon imported-icon" src="${c.iconSrc}"/>`;
        } else {
          str +=
            `<img id=${c.id} class="icon" src="/botc-script-tool/src/assets/unofficial-icons/Icon_${c.id}.webp"/>`;
        }
        str += `<div class="name-and-summary">`;
        str +=
          `<h4 class="character-name"><a href="${c.wikilink}" target="_blank">${c.name}</a></h4>`;
        str += `<div class="character-summary">${c.summary}</div>`;
        str += `</div>`;
        str += `</div>`;
      }
      str += `</div>`;
    }
    str += `</div>`;
    return str;
  }

  toJSON() {
    const obj = [
      {
        "id": "_meta",
        "author": this.author,
        "name": this.name,
      },
      ...this.townsfolk.map((c) => c.id),
      ...this.outsiders.map((c) => c.id),
      ...this.minions.map((c) => c.id),
      ...this.demons.map((c) => c.id),
    ];
    return JSON.stringify(obj);
  }
}
