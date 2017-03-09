const flash = ( state = {}, action ) => {
  switch ( action.type ) {
    case 'SET_FLASH':
      let { message, msgType } = action;
      return { message, msgType }
    case 'CLEAR_FLASH':
      return {}
    default:
      return state;
  }
}

export default flash;