// Exercise Node's actual package/module loader with the built manifest and bundle.
// Vicinae supplies these APIs at runtime; this probe only checks module loading.
const { execFileSync } = require("node:child_process");
const { mkdtempSync, rmSync } = require("node:fs");
const { tmpdir } = require("node:os");
const path = require("node:path");
const output = mkdtempSync(path.join(tmpdir(), "notes-bundle-"));
try {
  execFileSync(path.join(__dirname, "node_modules/.bin/vici"), ["build", "-o", output], { cwd: __dirname, stdio: "inherit" });
  const probe = `
    import Module from 'node:module';
    import { pathToFileURL } from 'node:url';
    const original = Module._load;
    Module._load = function(id, ...args) {
      if (id === '@vicinae/api' || id === 'react' || id === 'react/jsx-runtime') return {};
      return original.call(this, id, ...args);
    };
    import(pathToFileURL(process.argv[1]).href).then(result => {
      if (typeof result.default?.default !== 'function' && typeof result.default !== 'function')
        throw new Error('Missing Notes command export');
    }).catch(error => { console.error(error); process.exitCode = 1; });
  `;
  execFileSync(process.execPath, ["--input-type=module", "-e", probe, path.join(output, "notes.js")], { stdio: "inherit" });
  console.log("Built Notes command loads successfully.");
} finally {
  rmSync(output, { recursive: true, force: true });
}
