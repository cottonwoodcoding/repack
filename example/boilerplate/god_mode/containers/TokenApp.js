import React from 'react';
import { connect } from 'react-redux';
import Navbar from '../components/Navbar';
import FlashMessage from '../components/FlashMessage';
import { clearFlash } from '../actions/flash';
import Auth from 'j-toker';

class App extends React.Component {
  componentDidMount() {
    let { dispatch, history } = this.props;

    Auth.configure({
      apiUrl: '/api'
    });
    
    Auth.validateToken()
    .then( user => {
      dispatch({ type: 'LOGIN', ...user.data });
    })
    .fail( () => {
      history.push('/login');
    });
  }

  componentDidUpdate() {
    let { dispatch, history } = this.props;
    dispatch(clearFlash());
  }

  render() {
    let { auth, children } = this.props;

    return(
      <div>
        <Navbar />
        <div style={{ marginBottom: '30px' }}>
          <FlashMessage />
        </div>
        <div className='container'>
          { children }
        </div>
      </div>
    );
  }
}

export default connect()(App);

