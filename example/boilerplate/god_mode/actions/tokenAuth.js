import { browserHistory } from 'react-router';
import { setFlash } from './flash';
import Auth from 'j-toker';

const logout = () => {
  return { type: 'LOGOUT' }
}

const login = (user) => {
  return { type: 'LOGIN', user }
}

const authErrors = (errors) => {
  let message = '';
  let msgType = 'error';
  errors.forEach( error => {
    message += `${error} `
  });
  return { type: 'SET_FLASH', message, msgType }
}

export const handleLogin = (email, password) => {
  return(dispatch) => {
    Auth.emailSignIn({
      email,
      password
    }).then( user => {
      dispatch(login(user.data));
      browserHistory.push('/');
    }).fail( res => {
      dispatch(authErrors(res.data.errors));
    });
  }
}

export const handleLogout = () => {
  return(dispatch) => {
    Auth.signOut()
      .then( res => { 
        dispatch(logout());
        browserHistory.push('/login');
      });
  }
}

export const handleSignUp = (email, password) => {
  return(dispatch) => {
    Auth.emailSignUp({
      email,
      password,
      password_confirmation: password
    }).then( user => {
      dispatch(login(user.data));
      browserHistory.push('/');
    }).fail( res => {
      dispatch(authErrors(res.data.errors.full_messages));
    });
  }
}