import React from 'react';
import { Route, IndexRoute, browserHistory } from 'react-router';
import App from './containers/App';
import NoMatch from './components/NoMatch';
import Login from './components/Login';
import SignUp from './components/SignUp';
import { UserAuthWrapper } from 'redux-auth-wrapper';
import Loading from './components/Loading';

const UserIsAuthenticated = UserAuthWrapper({
  authSelector: state => state.auth,
  predicate: auth => auth.isAuthenticated,
  authenticatingSelector: state => state.auth.loading,
  LoadingComponent: Loading
});

export default (
  <Route>

    <Route path="/" component={App}>
      <Route path='/login' component={Login} />
      <Route path='/sign_up' component={SignUp} />
    </Route>

    <Route path="*" status={404} component={NoMatch} />
  </Route>
)