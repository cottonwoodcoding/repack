import { combineReducers } from 'redux';
import { routerReducer } from 'react-router-redux';
import auth from './auth'
import flash from './flash';

const rootReducer = combineReducers({ routing: routerReducer, auth, flash });

export default rootReducer;