import { useEffect, useRef, useState } from 'react'
import { applyFormat, LIST_FORMATS } from './format.js'

const LINKEDIN_LIMIT = 3000

// Roughly where LinkedIn cuts a post off with "...see more".
// LinkedIn doesn't publish exact numbers, so these are approximate.
const CUTOFFS = {
  desktop: { chars: 210, lines: 3 },
  mobile: { chars: 140, lines: 3 },
}

const TOOLBAR = [
  { format: 'bold', label: 'B', title: 'Bold (Ctrl/Cmd + B)', className: 'tb-bold' },
  { format: 'italic', label: 'I', title: 'Italic (Ctrl/Cmd + I)', className: 'tb-italic' },
  { format: 'boldItalic', label: 'BI', title: 'Bold italic', className: 'tb-bold tb-italic' },
  { format: 'strike', label: 'S', title: 'Strikethrough', className: 'tb-strike' },
  { format: 'bullets', label: '• List', title: 'Bullet list' },
  { format: 'numbers', label: '1. List', title: 'Numbered list' },
]

const SHORTCUTS = { b: 'bold', i: 'italic' }

// A small set of emoji people often use in LinkedIn posts. Kept in the code, so no download is needed.
const EMOJIS = [
  '🚀', '✅', '💡', '🔥', '👉', '📌', '🎯', '⚡', '🙌', '👏',
  '💪', '📈', '📉', '🛠️', '🧠', '⭐', '❌', '⚠️', '🔒', '🐳',
  '☁️', '💻', '📦', '🔧', '🧪', '📊', '📝', '🎉', '🤝', '👀',
  '1️⃣', '2️⃣', '3️⃣', '4️⃣', '5️⃣', '➡️', '⬇️', '🔹', '🔸', '💬',
]

const REACTIONS = [
  { label: 'Like', path: 'M7 10v10H4V10h3zm3 10h7.5a2 2 0 0 0 1.9-1.4l1.5-5A2 2 0 0 0 19 11h-4.5l.6-3.4A2.2 2.2 0 0 0 13 5l-3 5v10z' },
  { label: 'Comment', path: 'M4 5h16v11H9l-5 4V5z' },
  { label: 'Repost', path: 'M7 7h9l-2-2 1.4-1.4L20 8.2l-4.6 4.6L14 11.4l2-2.4H9v4H7V7zm10 10H8l2 2-1.4 1.4L4 15.8l4.6-4.6L10 12.6 8 15h7v-4h2v6z' },
  { label: 'Send', path: 'M3 4l18 8-18 8 3-8-3-8zm3.5 8L18 12' },
]

function Icon({ path }) {
  return (
    <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinejoin="round" aria-hidden="true">
      <path d={path} />
    </svg>
  )
}

function countWords(text) {
  return text.trim() ? text.trim().split(/\s+/).length : 0
}

// Websites can't open the device's own emoji picker, so we tell people the shortcut for their device.
function nativeEmojiTip() {
  const ua = navigator.userAgent
  const touch = navigator.maxTouchPoints > 1
  if (/iPhone|iPad|iPod|Android/i.test(ua) || (/Macintosh/i.test(ua) && touch)) {
    return 'For every emoji, tap the emoji key on your keyboard.'
  }
  if (/Mac/i.test(ua)) return 'For every emoji, press Fn + E (or Control + Command + Space).'
  if (/Windows/i.test(ua)) return 'For every emoji, press the Windows key + . (full stop).'
  return 'Your device may also have its own emoji keyboard.'
}

const STORAGE_KEY = 'post-prep-draft'

function loadDraft() {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY)) || {}
  } catch {
    return {}
  }
}

function buildPost({ body, hashtags }) {
  return [body.trim(), hashtags.trim()].filter(Boolean).join('\n\n')
}

function cutOff(text, { chars, lines }) {
  const firstLines = text.split('\n').slice(0, lines).join('\n')
  // Array.from keeps styled letters whole. They are stored as two units each.
  // trimEnd stops "...see more" dropping onto its own line when the cut lands on a blank line.
  const shown = Array.from(firstLines).slice(0, chars).join('').trimEnd()
  return { shown, isCut: shown.length < text.trimEnd().length }
}

export default function App() {
  const saved = loadDraft()
  const [body, setBody] = useState(saved.body ?? '')
  const [hashtags, setHashtags] = useState(saved.hashtags ?? '')
  const [name, setName] = useState(saved.name ?? '')
  const [headline, setHeadline] = useState(saved.headline ?? '')
  const [dark, setDark] = useState(
    saved.dark ?? window.matchMedia('(prefers-color-scheme: dark)').matches
  )
  const [device, setDevice] = useState('mobile')
  const [expanded, setExpanded] = useState(false)
  const [copied, setCopied] = useState(false)
  const [hint, setHint] = useState('')
  const [showEmojis, setShowEmojis] = useState(false)
  const [confirmClear, setConfirmClear] = useState(false)
  const editor = useRef(null)

  useEffect(() => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify({ body, hashtags, name, headline, dark }))
    } catch {
      // Storage can be unavailable (e.g. private browsing). The app still works without it.
    }
  }, [body, hashtags, name, headline, dark])

  useEffect(() => {
    document.documentElement.dataset.theme = dark ? 'dark' : 'light'
  }, [dark])

  const post = buildPost({ body, hashtags })
  const preview = cutOff(post, CUTOFFS[device])
  const overLimit = post.length > LINKEDIN_LIMIT
  const usedPercent = Math.min(100, (post.length / LINKEDIN_LIMIT) * 100)
  const displayName = name.trim() || 'Your Name'
  const words = countWords(post)
  const readSeconds = Math.round((words / 200) * 60)

  function showHint(message) {
    setHint(message)
    setTimeout(() => setHint(''), 2500)
  }

  // Replaces text in the box through the browser's own editing, so Ctrl/Cmd + Z and the Undo button work.
  function replaceText(box, start, end, newText) {
    box.focus()
    box.setSelectionRange(start, end)
    const inserted = document.execCommand('insertText', false, newText)
    if (!inserted) setBody(box.value.slice(0, start) + newText + box.value.slice(end))
  }

  function format(formatName) {
    const box = editor.current
    let start = box.selectionStart
    let end = box.selectionEnd

    // Lists work on whole lines, so the cursor just needs to be somewhere on the line.
    if (LIST_FORMATS.includes(formatName)) {
      if (end > start && body[end - 1] === '\n') end -= 1
      start = body.lastIndexOf('\n', start - 1) + 1
      const lineEnd = body.indexOf('\n', end)
      end = lineEnd === -1 ? body.length : lineEnd
    } else if (start === end) {
      showHint('Select some text first, then choose a style.')
      box.focus()
      return
    }

    const changed = applyFormat(body.slice(start, end), formatName)
    replaceText(box, start, end, changed)
    // Keep the same text selected so styles can be stacked or undone.
    requestAnimationFrame(() => box.setSelectionRange(start, start + changed.length))
  }

  function insertEmoji(emoji) {
    const box = editor.current
    const start = box.selectionStart
    replaceText(box, start, box.selectionEnd, emoji)
    requestAnimationFrame(() => box.setSelectionRange(start + emoji.length, start + emoji.length))
    setShowEmojis(false)
  }

  // Empties the text box. Done through the browser's editing, so Undo can bring the text back.
  function clearAll() {
    const box = editor.current
    if (!box.value) return
    box.focus()
    box.select()
    const deleted = document.execCommand('delete')
    if (!deleted) setBody('')
    setExpanded(false)
  }

  function undo() {
    editor.current.focus()
    const undone = document.execCommand('undo')
    if (!undone) showHint('Nothing to undo.')
  }

  function handleShortcut(event) {
    if (event.key === 'Escape') setShowEmojis(false)
    const formatName = SHORTCUTS[event.key.toLowerCase()]
    if (formatName && (event.metaKey || event.ctrlKey)) {
      event.preventDefault()
      format(formatName)
    }
  }

  async function copyPost() {
    try {
      await navigator.clipboard.writeText(post)
    } catch {
      // Clipboard API needs HTTPS. Fall back to the older method over plain HTTP.
      const box = document.createElement('textarea')
      box.value = post
      document.body.appendChild(box)
      box.select()
      document.execCommand('copy')
      box.remove()
    }
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  function startNewPost() {
    // Ask for a second click so a draft can't be wiped by accident.
    if (!confirmClear) {
      setConfirmClear(true)
      setTimeout(() => setConfirmClear(false), 3000)
      return
    }
    setBody('')
    setExpanded(false)
    setConfirmClear(false)
    editor.current.focus()
  }

  return (
    <div className="app">
      <header className="top">
        <div className="top-inner">
          <div className="logo">P</div>
          <div className="brand">
            <h1>Post Prep</h1>
            <p>Write, format and preview a LinkedIn post before it goes out.</p>
          </div>
          <button className="theme" onClick={() => setDark(!dark)} aria-label="Switch between light and dark">
            {dark ? 'Light mode' : 'Dark mode'}
          </button>
        </div>
      </header>

      <main className="grid">
        <section className="card">
          <div className="card-head">
            <h2>Write</h2>
          </div>

          <div className="editor">
            <div className="toolbar">
              {TOOLBAR.map((tool) => (
                <button
                  key={tool.format}
                  type="button"
                  title={tool.title}
                  aria-label={tool.title}
                  className={tool.className}
                  onMouseDown={(e) => e.preventDefault()}
                  onClick={() => format(tool.format)}
                >
                  {tool.label}
                </button>
              ))}
              <button
                type="button"
                title="Clear all text (Undo brings it back)"
                aria-label="Clear all text"
                onMouseDown={(e) => e.preventDefault()}
                onClick={clearAll}
              >
                Clear
              </button>
              <span className="divider" />
              <button
                type="button"
                title="Add emoji"
                aria-label="Add emoji"
                aria-expanded={showEmojis}
                onMouseDown={(e) => e.preventDefault()}
                onClick={() => setShowEmojis(!showEmojis)}
              >
                🙂
              </button>
              <button
                type="button"
                title="Undo (Ctrl/Cmd + Z)"
                aria-label="Undo"
                onMouseDown={(e) => e.preventDefault()}
                onClick={undo}
              >
                ↶ Undo
              </button>
              {hint && <span className="hint">{hint}</span>}
            </div>
            {showEmojis && (
              <div className="emoji-panel" role="dialog" aria-label="Choose an emoji">
                <p className="emoji-tip">{nativeEmojiTip()}</p>
                {EMOJIS.map((emoji) => (
                  <button
                    key={emoji}
                    type="button"
                    aria-label={`Insert ${emoji}`}
                    onMouseDown={(e) => e.preventDefault()}
                    onClick={() => insertEmoji(emoji)}
                  >
                    {emoji}
                  </button>
                ))}
              </div>
            )}
            <textarea
              ref={editor}
              aria-label="Post text"
              placeholder="Start with your hook..."
              value={body}
              onChange={(e) => setBody(e.target.value)}
              onKeyDown={handleShortcut}
            />
          </div>

          <label className="field">
            Hashtags (optional)
            <input
              placeholder="#YourTopic #AnotherTopic"
              value={hashtags}
              onChange={(e) => setHashtags(e.target.value)}
            />
          </label>

          <div className="meter">
            <div className={`meter-fill ${overLimit ? 'over' : ''}`} style={{ width: `${usedPercent}%` }} />
          </div>
          <div className="stats">
            <span className={`stat ${overLimit ? 'over' : ''}`}>
              <strong>{post.length.toLocaleString()}</strong> / {LINKEDIN_LIMIT.toLocaleString()} characters
              {overLimit && ` (${(post.length - LINKEDIN_LIMIT).toLocaleString()} over)`}
            </span>
            <span className="stat">
              <strong>{words.toLocaleString()}</strong> words
            </span>
            <span className="stat">
              <strong>{readSeconds < 60 ? `${readSeconds}s` : `${Math.round(readSeconds / 60)} min`}</strong> read
            </span>
          </div>

          <div className="actions">
            <button className="primary" onClick={copyPost} disabled={!post}>
              {copied ? 'Copied!' : 'Copy post'}
            </button>
            <button onClick={startNewPost} disabled={!body}>
              {confirmClear ? 'Click again to clear' : 'New post'}
            </button>
          </div>
        </section>

        <section className="card">
          <div className="card-head">
            <h2>Preview</h2>
            <div className="toggle">
              {Object.keys(CUTOFFS).map((d) => (
                <button key={d} className={device === d ? 'active' : ''} onClick={() => setDevice(d)}>
                  {d}
                </button>
              ))}
            </div>
          </div>

          <div className={`stage ${device}`}>
            <div className="feed-post">
              <div className="author">
                <div className="avatar">{displayName[0].toUpperCase()}</div>
                <div>
                  <div className="author-name">{displayName}</div>
                  <div className="author-headline">{headline.trim() || 'Your headline'}</div>
                  <div className="author-headline">Just now</div>
                </div>
              </div>
              {post ? (
                <p className="post-text">
                  {expanded ? post : preview.shown}
                  {!expanded && preview.isCut && <span className="see-more"> …see more</span>}
                </p>
              ) : (
                <p className="post-text muted">Your post will appear here.</p>
              )}
              <div className="reactions">
                {REACTIONS.map((reaction) => (
                  <span key={reaction.label}>
                    <Icon path={reaction.path} />
                    {reaction.label}
                  </span>
                ))}
              </div>
            </div>
          </div>

          <div className="preview-foot">
            <span className="muted small">The cut-off point is approximate.</span>
            {(preview.isCut || expanded) && (
              <button className="link" onClick={() => setExpanded(!expanded)}>
                {expanded ? 'Show cut-off view' : 'Show full post'}
              </button>
            )}
          </div>

          <div className="profile">
            <label className="field">
              Name on the preview
              <input placeholder="Your Name" value={name} onChange={(e) => setName(e.target.value)} />
            </label>
            <label className="field">
              Headline
              <input placeholder="Your headline" value={headline} onChange={(e) => setHeadline(e.target.value)} />
            </label>
          </div>
        </section>
      </main>

      <footer className="foot">Your draft is saved in this browser only. Nothing is sent anywhere.</footer>
    </div>
  )
}
