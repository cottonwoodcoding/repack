const auth = (state = {}, action) => {
  switch(action.type) {
    case 'LOGIN':
      return {
        isAuthenticated: true,
        user: action
      }
    case 'LOGOUT':
      return {}
    default:
     return state;
  }
}

export default auth;