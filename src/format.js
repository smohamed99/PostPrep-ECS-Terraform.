// LinkedIn has no bold or italic button for posts.
// Formatters work by swapping normal letters for look-alike Unicode letters,
// and by adding a "combining" mark after each character for strikethrough.

const UPPER_A = 65
const LOWER_A = 97
const ZERO = 48

// Where each styled alphabet starts in Unicode.
const LETTER_STYLES = {
  bold: { upper: 0x1d5d4, lower: 0x1d5ee, digit: 0x1d7ec },
  italic: { upper: 0x1d608, lower: 0x1d622 },
  boldItalic: { upper: 0x1d63c, lower: 0x1d656 },
}

const MARKS = {
  strike: '\u0336',
}

function inRange(code, start, length) {
  return start !== undefined && code >= start && code < start + length
}

// Turn styled letters back into normal ones. Underline and strikethrough marks are kept.
export function plainLetters(text) {
  return Array.from(text)
    .map((char) => {
      const code = char.codePointAt(0)
      for (const style of Object.values(LETTER_STYLES)) {
        if (inRange(code, style.upper, 26)) return String.fromCharCode(UPPER_A + code - style.upper)
        if (inRange(code, style.lower, 26)) return String.fromCharCode(LOWER_A + code - style.lower)
        if (inRange(code, style.digit, 10)) return String.fromCharCode(ZERO + code - style.digit)
      }
      return char
    })
    .join('')
}

function styleLetters(text, styleName) {
  const style = LETTER_STYLES[styleName]
  return Array.from(plainLetters(text))
    .map((char) => {
      const code = char.codePointAt(0)
      if (inRange(code, UPPER_A, 26)) return String.fromCodePoint(style.upper + code - UPPER_A)
      if (inRange(code, LOWER_A, 26)) return String.fromCodePoint(style.lower + code - LOWER_A)
      if (style.digit && inRange(code, ZERO, 10)) return String.fromCodePoint(style.digit + code - ZERO)
      return char
    })
    .join('')
}

// Splits text into the characters a person sees, so emoji and already-marked letters stay whole.
function visibleCharacters(text) {
  if (typeof Intl !== 'undefined' && Intl.Segmenter) {
    return Array.from(new Intl.Segmenter().segment(text), (part) => part.segment)
  }
  return Array.from(text)
}

function toggleMark(text, mark) {
  if (text.includes(mark)) return text.replaceAll(mark, '')
  return visibleCharacters(text)
    .map((char) => (char === '\n' || /\p{Extended_Pictographic}/u.test(char) ? char : char + mark))
    .join('')
}

const BULLET = /^• /
const NUMBER = /^\d+\. /

// Removes any existing bullet or number so a line can be switched between list types.
function stripListMarker(line) {
  return line.replace(BULLET, '').replace(NUMBER, '')
}

function toggleList(text, type) {
  const lines = text.split('\n')
  const marker = type === 'bullets' ? BULLET : NUMBER
  const alreadyThisType = lines.every((line) => !line.trim() || marker.test(line))
  let count = 0
  return lines
    .map((line) => {
      if (!line.trim()) return line
      const plain = stripListMarker(line)
      if (alreadyThisType) return plain
      count += 1
      return type === 'bullets' ? `• ${plain}` : `${count}. ${plain}`
    })
    .join('\n')
}

export const LIST_FORMATS = ['bullets', 'numbers']

export function applyFormat(text, format) {
  if (format in LETTER_STYLES) {
    const styled = styleLetters(text, format)
    return styled === text ? plainLetters(text) : styled
  }
  if (format in MARKS) return toggleMark(text, MARKS[format])
  if (format === 'bullets' || format === 'numbers') return toggleList(text, format)
  return text
}
