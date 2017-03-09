import React from 'react';

class Loading extends React.Component {
  constructor(props) {
    super(props);
    this.state = { isLoading: false };
    let destructTimeout;
  }

  componentDidMount() {
    this.setState({ isLoading: true });
  }

  componentWillUnmount() {
    clearTimeout(this.destructTimeout);
  }

  selfDestruct = () => {
    this.destructTimeout = setTimeout( () => {
      this.setState({ isLoading: false });
    }, 3000);
  }

  render() {
    if(this.state.isLoading) {
      this.selfDestruct();
    } else {
      clearTimeout(this.destructTimeout);
    }

    return (
      <div>
        { this.state.isLoading ?
          <span className="loading">{`Loading ${this.props.info}`}</span>
          :
          <span>{`No ${this.props.info} found`}</span>
        }
      </div>
    )
  }
}

Loading.proptypes = {
  info: React.PropTypes.string.isRequired
}

export default Loading;