import React, { Component } from 'react';
import home from '@assets/images/welcome.png';
import './style/index.less';

class Home extends Component {
    render() {
        return (
            <main className="home">
                <div className="img-box">
                    <img src={home} alt="" />
                </div>
            </main>
        );
    }
};

export default Home;