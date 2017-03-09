import React from 'react';
import { Link } from 'react-router';
import { handleSignUp } from '../actions/auth';
import { connect } from 'react-redux';

class SignUp extends React.Component { 
  handleSubmit = (e) => {
    e.preventDefault();
    let email = this.refs.email.value;
    let password = this.refs.password.value;
    this.props.dispatch(handleSignUp(email, password));
  }

  render() {
    return(
      <div className='center'>
        <h3>Sign Up For A New Account</h3>
        <form onSubmit={ this.handleSubmit }>
          <input ref='email' type='text' required placeholder='Email' />
          <br />
          <input ref='password' type='password' required placeholder='Password' />
          <br />
          <input type='submit' className='btn' value='Sign Up' />
          <Link to='/login' className='btn grey'>Cancel</Link>
        </form>
      </div>
    );
  }
}

export default connect()(SignUp);