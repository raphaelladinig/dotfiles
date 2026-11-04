// DARK_READER_SOURCE supplies src/defaults.ts, src/background/user-storage.ts,
// and src/background/utils/extension-api.ts from a Dark Reader checkout.
// Verified with e79222971bcae472a28f20de67c07d5a6de45148 (4.9.134).
import {readFileSync} from 'node:fs';
import {stripTypeScriptTypes} from 'node:module';
import {resolve} from 'node:path';

const [local, sync] = JSON.parse(readFileSync(0, 'utf8'));
const area = (data) => ({
    QUOTA_BYTES_PER_ITEM: 8192,
    get(keys, callback) {
        callback(keys === null ? structuredClone(data) : Object.fromEntries(
            Object.entries(keys).map(([key, value]) => [key, key in data ? structuredClone(data[key]) : value]),
        ));
    },
    set(values, callback) { Object.assign(data, structuredClone(values)); callback(); },
    remove(keys, callback) { for (const key of keys) delete data[key]; callback(); },
});
const chrome = {storage: {local: area(local), sync: area(sync)}, runtime: {}};
const readSource = (name) => readFileSync(resolve(process.argv[2], 'src', name), 'utf8')
    .replace(/^import .*;\n/gm, '')
    .replace(/export default class UserStorage/, 'class UserStorage')
    .replace(/^export /gm, '');
const source = `
const __PLUS__ = false, __CHROMIUM_MV3__ = true;
const isMacOS = true, isWindows = false, isCSSColorSchemePropSupported = true;
const isEdge = false, isMobile = false, isFirefox = false;
const AutomationMode = {SYSTEM: 'system', NONE: ''};
const ThemeEngine = {dynamicTheme: 'dynamicTheme', cssFilter: 'cssFilter', svgFilter: 'svgFilter'};
const debounce = (fn) => fn;
const validateSettings = () => ({errors: []});
const logWarn = () => {};
class PromiseBarrier {
    constructor() { this.promise = new Promise((resolve) => { this.resolve = resolve; }); }
    entry() { return this.promise; }
}
${readSource('defaults.ts')}
${readSource('background/utils/extension-api.ts')}
${readSource('background/user-storage.ts')}
`;
const UserStorage = new Function('chrome', stripTypeScriptTypes(source) + '\nreturn UserStorage;')(chrome);
await UserStorage.loadSettings();
const {enabledByDefault, enabledFor, disabledFor} = UserStorage.settings;
process.stdout.write(JSON.stringify({enabledByDefault, enabledFor, disabledFor}));
