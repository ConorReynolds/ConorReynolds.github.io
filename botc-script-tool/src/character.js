// import fuzzysort from "./fuzzysort.js";
import { charmap } from "./data.js";
export class Character {
  id;
  static data = charmap;
  static flat = Object.entries(charmap).map(([k, v]) => {
    return Object.assign({ id: k }, v);
  });
  constructor(id) {
    if (Character.data[id]) {
      this.id = id;
    } else {
      throw new Error("invalid character construction");
    }
  }
  valueOf() {
    return this.id;
  }
  get name() {
    return Character.data[this.id]["Name"];
  }
  get summary() {
    return Character.data[this.id]["Summary"];
  }
  get type() {
    return Character.data[this.id]["Type"];
  }
  get homeScript() {
    return Character.data[this.id]["Script"];
  }
  get wikilink() {
    // the display name works, but I added some proper apostrophes which need
    // to be reverted to straight quotes first
    const cleaned = this.name.replace("’", "'");
    return `https://wiki.bloodontheclocktower.com/${cleaned}`;
  }
  get summaryLength() {
    return this.summary.length;
  }
  static nameToID(name) {
    let id = name;
    id = id.replace("’", "");
    id = id.replace(" ", "_");
    id = id.toLowerCase();
    return id;
  }
  static fuzzyMatch(str) {
    const results = fuzzysort.go(str, Character.flat, { key: "Name" });
    if (results.length === 0) {
      return {
        result: [],
        match: null,
      };
    }
    console.log(results);
    return {
      result: results.slice(0, 8).map((
        r,
      ) => [Character.nameToID(r.target), r.highlight("<b>", "</b>")]),
      match: new Character(Character.nameToID(results[0].target)),
    };
  }
  get firstNight() {
    return Character.data[this.id]["first night"];
  }
  get eachNight() {
    return Character.data[this.id]["each night"];
  }
  get eachNightStar() {
    return Character.data[this.id]["each night*"];
  }
  get day() {
    return Character.data[this.id]["day"];
  }
  get oncePerGame() {
    return Character.data[this.id]["once per game"];
  }
  get actsOnTrigger() {
    return Character.data[this.id]["on trigger"];
  }
  get isPassive() {
    return Character.data[this.id]["passive"];
  }
  get team() {
    if (this.type === "Townsfolk" || this.type === "Outsider") {
      return "Good";
    } else {
      return "Evil";
    }
  }
  static typeRank(t) {
    switch (t) {
      case "Townsfolk":
        return 1;
      case "Outsider":
        return 2;
      case "Minion":
        return 3;
      case "Demon":
        return 4;
      default:
        throw Error(`not a valid character type: ${t}`);
    }
  }
  static compare(c1, c2) {
    // Sort teams and types.
    const type1 = Character.typeRank(c1.type);
    const type2 = Character.typeRank(c2.type);
    if (type1 < type2) {
      return -1;
    }
    if (type2 < type1) {
      return 1;
    }
    // Standard Amy Order
    // - handle exceptions to the remaining rules
    // - first night
    // - every night
    // - every night*
    // - day
    // - once per game
    // - on trigger
    // - passive
    // - length of ability text
    const c1CompareString = [
      c1.firstNight,
      c1.eachNight,
      c1.eachNightStar,
      c1.day,
      c1.oncePerGame,
      c1.actsOnTrigger || c1.isPassive,
    ]
      .map((b) => (b ? 0 : 1))
      .join("");
    const c2CompareString = [
      c2.firstNight,
      c2.eachNight,
      c2.eachNightStar,
      c2.day,
      c2.oncePerGame,
      c2.actsOnTrigger || c2.isPassive,
    ]
      .map((b) => (b ? 0 : 1))
      .join("");
    if (c1CompareString < c2CompareString) {
      return -1;
    }
    if (c2CompareString < c1CompareString) {
      return 1;
    }
    if (c1.summaryLength < c2.summaryLength) {
      return -1;
    }
    if (c2.summaryLength < c1.summaryLength) {
      return 1;
    }
    return 0;
  }
}
