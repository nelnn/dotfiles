import { readdir, stat, mkdir, open, realpath } from "node:fs/promises";
import path from "node:path";
import os from "node:os";

export type Note = { file: string; relative: string; modified: number };
export function notesRoot(value: string) {
  return path.resolve(value === "~" ? os.homedir() : value.startsWith("~/") ? path.join(os.homedir(), value.slice(2)) : value);
}
export async function scanNotes(root: string) {
  const notes: Note[] = [];
  const directories = [""];
  async function visit(relative: string) {
    let entries;
    try { entries = await readdir(path.join(root, relative), { withFileTypes: true }); }
    catch (error) {
      if ((error as NodeJS.ErrnoException).code === "ENOENT" && !relative) return;
      throw error;
    }
    for (const entry of entries) {
      if (entry.name.startsWith(".")) continue;
      const rel = path.join(relative, entry.name);
      if (entry.isDirectory()) { directories.push(rel); await visit(rel); }
      else if (entry.isFile() && /\.md$/i.test(entry.name)) {
        const file = path.join(root, rel);
        notes.push({ file, relative: rel, modified: (await stat(file)).mtimeMs });
      }
    }
  }
  await visit("");
  notes.sort((a, b) => b.modified - a.modified || a.relative.localeCompare(b.relative));
  directories.sort();
  return { notes, directories };
}
export function defaultName(now = new Date()) {
  const local = new Date(Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()));
  const date = local.toISOString().slice(0, 10);
  local.setUTCDate(local.getUTCDate() + 4 - (local.getUTCDay() || 7));
  const yearStart = new Date(Date.UTC(local.getUTCFullYear(), 0, 1));
  const week = Math.ceil(((local.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
  return `${date}-w${String(week).padStart(2, "0")}`;
}
export async function createNote(root: string, directory: string, name: string) {
  name = name.trim() || defaultName();
  if (name === "." || name === ".." || /[/\\\x00-\x1f]/.test(name)) throw new Error("Use a filename, without slashes or control characters.");
  const target = path.resolve(root, directory);
  if (target !== root && !target.startsWith(root + path.sep)) throw new Error("Directory must be inside the notes folder.");
  await mkdir(root, { recursive: true });
  const actualRoot = await realpath(root);
  const actualTarget = await realpath(target);
  if (actualTarget !== actualRoot && !actualTarget.startsWith(actualRoot + path.sep)) throw new Error("Directory must be inside the notes folder.");
  const file = path.join(actualTarget, /\.md$/i.test(name) ? name : `${name}.md`);
  const handle = await open(file, "wx");
  await handle.close();
  return file;
}
