const auth = (state = { loading: true }, action) => {
  switch(action.type) {
    case 'LOGIN':
      return {
        isAuthenticated: true,
        loading: false,
        ...action.user
      }
    case 'LOGOUT':
      return {}
    default:
     return state;
  }
}

export default auth;