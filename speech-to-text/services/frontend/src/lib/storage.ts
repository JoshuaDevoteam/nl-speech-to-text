const hasWindow = () => typeof window !== 'undefined'

export function loadJSON<T>(key: string): T | null {
  if (!hasWindow()) return null
  try {
    const raw = window.localStorage.getItem(key)
    if (!raw) return null
    return JSON.parse(raw) as T
  } catch (error) {
    console.error(`Failed to parse localStorage key "${key}"`, error)
    return null
  }
}

export function saveJSON<T>(key: string, value: T): void {
  if (!hasWindow()) return
  try {
    window.localStorage.setItem(key, JSON.stringify(value))
  } catch (error) {
    console.error(`Failed to save localStorage key "${key}"`, error)
  }
}

export function removeStoredItem(key: string): void {
  if (!hasWindow()) return
  try {
    window.localStorage.removeItem(key)
  } catch (error) {
    console.error(`Failed to remove localStorage key "${key}"`, error)
  }
}

export function loadSession<T>(key: string): T | null {
  if (!hasWindow()) return null
  try {
    const raw = window.sessionStorage.getItem(key)
    if (!raw) return null
    return JSON.parse(raw) as T
  } catch (error) {
    console.error(`Failed to parse sessionStorage key "${key}"`, error)
    return null
  }
}

export function saveSession<T>(key: string, value: T): void {
  if (!hasWindow()) return
  try {
    window.sessionStorage.setItem(key, JSON.stringify(value))
  } catch (error) {
    console.error(`Failed to save sessionStorage key "${key}"`, error)
  }
}

export function removeSessionItem(key: string): void {
  if (!hasWindow()) return
  try {
    window.sessionStorage.removeItem(key)
  } catch (error) {
    console.error(`Failed to remove sessionStorage key "${key}"`, error)
  }
}

export const storageUtils = {
  loadJSON,
  saveJSON,
  removeStoredItem,
  loadSession,
  saveSession,
  removeSessionItem,
}
