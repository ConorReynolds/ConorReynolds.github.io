import { Script } from "./script.js";
import { Timeline } from "./timeline.js";
export class AppState {
    constructor(scripts) {
        if (scripts.length === 0) {
            throw Error(`Must have at least one script!`);
        }
        this.scripts = scripts;
        this.timelines = scripts.map((s) => s.timeline);
        this.currentScriptIdx = 0;
        this.capacity = 15;
    }
    get currentScript() {
        return this.scripts[this.currentScriptIdx];
    }
    setCurrentScript(script) {
        this.scripts[this.currentScriptIdx] = script;
    }
    nextScript() {
        this.currentScriptIdx = Math.min(this.currentScriptIdx + 1, this.scripts.length - 1);
    }
    prevScript() {
        this.currentScriptIdx = Math.max(this.currentScriptIdx - 1, 0);
    }
    focusScript(idx) {
        idx = idx !== null && idx !== void 0 ? idx : this.scripts.length - 1;
        if (0 <= idx && idx < this.scripts.length) {
            this.currentScriptIdx = idx;
            return true;
        }
        else {
            return false;
        }
    }
    addScript(script, idx, force) {
        idx = idx !== null && idx !== void 0 ? idx : this.scripts.length;
        force = force !== null && force !== void 0 ? force : false;
        if (!force && this.scripts.length === 1 && this.scripts[0].isEmpty()) {
            this.scripts[0] = script;
            this.currentScriptIdx = 0;
            return true;
        }
        else if (this.scripts.length < this.capacity) {
            this.scripts.splice(idx, 0, script);
            this.timelines.splice(idx, 0, script.timeline);
            if (this.currentScriptIdx < idx) {
                this.currentScriptIdx = Math.min(this.currentScriptIdx + 1, this.capacity - 1);
            }
            return true;
        }
        else {
            this.scripts.splice(0, 1);
            this.timelines.splice(0, 1);
            this.scripts.splice(idx, 0, script);
            this.timelines.splice(idx, 0, script.timeline);
            if (this.currentScriptIdx < idx) {
                this.currentScriptIdx = Math.min(this.currentScriptIdx + 1, this.capacity - 1);
            }
            return false;
        }
    }
    addScriptAndFocus(script, idx, force) {
        idx = idx !== null && idx !== void 0 ? idx : this.scripts.length;
        force = force !== null && force !== void 0 ? force : false;
        if (this.addScript(script, idx, force)) {
            return this.focusScript(idx);
        }
        else if (0 <= idx && idx < this.scripts.length) {
            return this.focusScript(idx);
        }
        else {
            return false;
        }
    }
    removeScript(idx) {
        if (0 <= idx && idx < this.scripts.length) {
            this.scripts.splice(idx, 1);
            this.timelines.splice(idx, 1);
            if (this.currentScriptIdx >= idx) {
                this.currentScriptIdx = Math.max(this.currentScriptIdx - 1, 0);
            }
            return true;
        }
        else {
            return false;
        }
    }
    serialize() {
        const scripts = this.scripts.map((s) => s.toJSON());
        const timelines = this.scripts.map((s) => s.timeline);
        return JSON.stringify({
            scripts: scripts,
            timelines: timelines,
            currentScriptIdx: this.currentScriptIdx,
            capacity: this.capacity,
        });
    }
    static deserialize(str) {
        const obj = JSON.parse(str);
        const scriptStrs = obj.scripts;
        const timelines = obj.timelines;
        const currentScriptIdx = obj.currentScriptIdx;
        const scripts = [];
        for (const [i, s] of scriptStrs.entries()) {
            const localScript = new Script();
            const localTimeline = Timeline.deserialize(JSON.stringify(timelines[i]));
            localScript.isRecording = false;
            localScript.loadFromJSON(JSON.parse(s));
            localScript.timeline = localTimeline;
            localScript.isRecording = true;
            scripts.push(localScript);
        }
        const appState = new AppState(scripts);
        appState.focusScript(currentScriptIdx);
        return appState;
    }
    renderFileSelector() {
        let html = `<div class="file-selector-container">`;
        for (const [idx, script] of this.scripts.entries()) {
            html += `<div class="item">`;
            html +=
                `<button type="button"><i class="fa-solid fa-xmark"></i></button>`;
            html += `<div class="script-name ${this.currentScriptIdx === idx ? "selected" : ""}">${script.name !== "" ? script.name : "New Script"}</div>`;
            html += `</div>`;
        }
        html += `</div>`;
        html +=
            `<div class="nscripts" data-n="${this.scripts.length}">COUNT = ${this.scripts.length}</div>`;
        return html;
    }
}
//# sourceMappingURL=state.js.map