const auth = (state = {}, action) => {
  switch(action.type) {
    case 'LOGIN':
      return {
        isAuthenticated: true,
        ...action.user
      }
    case 'LOGOUT':
      return {}
    default:
     return state;
  }
}

export default auth;