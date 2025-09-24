const isBrowser = () => typeof window !== 'undefined'

export function loadJSON<T>(key: string): T | null {
  if (!isBrowser()) return null
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
  if (!isBrowser()) return
  try {
    window.localStorage.setItem(key, JSON.stringify(value))
  } catch (error) {
    console.error(`Failed to save localStorage key "${key}"`, error)
  }
}

export function removeStoredItem(key: string): void {
  if (!isBrowser()) return
  try {
    window.localStorage.removeItem(key)
  } catch (error) {
    console.error(`Failed to remove localStorage key "${key}"`, error)
  }
}

export const storageUtils = {
  loadJSON,
  saveJSON,
  removeStoredItem,
}
