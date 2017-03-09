export const clearFlash = () => {
  return { type: "CLEAR_FLASH" }
}

export const setFlash = (message, msgType) => {
  return {
    type: 'SET_FLASH',
    message,
    msgType
  }
}