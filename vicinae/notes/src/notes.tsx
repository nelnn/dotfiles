import { Action, ActionPanel, Form, Icon, List, Toast, closeMainWindow, getPreferenceValues, openExtensionPreferences, showToast, useNavigation } from "@vicinae/api";
import { useEffect, useState } from "react";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import path from "node:path";
import { createNote, defaultName, notesRoot, scanNotes, type Note } from "./notes-store";

const exec = promisify(execFile);
async function failure(error: unknown) {
  await showToast({ style: Toast.Style.Failure, title: "Notes", message: error instanceof Error ? error.message : String(error) });
}
async function editNote(file: string) {
  // open -na gives Ghostty a fresh instance; execFile keeps filenames out of a shell.
  await exec("/usr/bin/open", ["-na", "Ghostty", "--args", `--working-directory=${path.dirname(file)}`, "-e", "/opt/homebrew/bin/nvim", "--", file]);
  await closeMainWindow();
}
function NewNote({ root, directories, refresh }: { root: string; directories: string[]; refresh: () => void }) {
  const { pop } = useNavigation();
  const [name, setName] = useState(defaultName());
  const [directory, setDirectory] = useState("");
  async function submit() {
    try {
      const file = await createNote(root, directory, name);
      refresh();
      pop();
      await editNote(file);
    } catch (error) { await failure(error); }
  }
  return <Form navigationTitle="New Note" actions={<ActionPanel><Action.SubmitForm title="Create and Open" onSubmit={submit} /></ActionPanel>}>
    <Form.Dropdown id="directory" title="Directory" value={directory} onChange={setDirectory}>
      {directories.map(dir => <Form.Dropdown.Item key={dir} value={dir} title={dir || "Notes root"} />)}
    </Form.Dropdown>
    <Form.TextField id="name" title="Name" value={name} onChange={setName} placeholder={defaultName()} />
    <Form.Description text={`Markdown files in ${root}. Existing notes are never overwritten.`} />
  </Form>;
}
export default function Notes() {
  const root = notesRoot(getPreferenceValues<{ notesDirectory: string }>().notesDirectory);
  const [notes, setNotes] = useState<Note[]>([]);
  const [directories, setDirectories] = useState([""]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const { push } = useNavigation();
  async function refresh() {
    setLoading(true);
    try { const result = await scanNotes(root); setNotes(result.notes); setDirectories(result.directories); setError(""); }
    catch (error) { setError(error instanceof Error ? error.message : String(error)); }
    finally { setLoading(false); }
  }
  useEffect(() => { void refresh(); }, [root]);
  const newNote = () => push(<NewNote root={root} directories={directories} refresh={() => void refresh()} />);
  const common = <>
    <Action title="New Note" icon={Icon.Plus} shortcut={{ modifiers: ["cmd"], key: "n" }} onAction={newNote} />
    <Action title="Refresh" icon={Icon.ArrowClockwise} shortcut={{ modifiers: ["cmd"], key: "r" }} onAction={refresh} />
    <Action title="Configure Notes Folder" icon={Icon.Cog} onAction={openExtensionPreferences} />
  </>;
  return <List isLoading={loading} searchBarPlaceholder="Search notes by name or folder…">
    <List.Section>
      <List.Item title="New Note" subtitle={root} icon={Icon.Plus} actions={<ActionPanel>{common}</ActionPanel>} />
      {error && <List.Item title="Could not read notes folder" subtitle={error} icon={Icon.Warning} actions={<ActionPanel><Action title="Configure Notes Folder" onAction={openExtensionPreferences} /><Action title="Retry" onAction={refresh} /></ActionPanel>} />}
    </List.Section>
    <List.Section title="Notes" subtitle={`${notes.length} · newest first`}>
      {notes.map(note => <List.Item key={note.file} title={path.basename(note.relative, path.extname(note.relative))} subtitle={path.dirname(note.relative) === "." ? "" : path.dirname(note.relative)} keywords={[note.relative]} icon={Icon.BlankDocument} accessories={[{ text: new Date(note.modified) }]} actions={<ActionPanel>
        <Action title="Open in Neovim" icon={Icon.Terminal} onAction={() => editNote(note.file).catch(failure)} />
        {common}
      </ActionPanel>} />)}
    </List.Section>
  </List>;
}
