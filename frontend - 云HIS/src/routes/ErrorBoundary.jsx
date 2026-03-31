import React from 'react';
import store from '@store';
import Error from '@components/error404';

class ErrorBoundary extends React.Component {
    constructor(props) {
        super(props);
        this.state = { hasError: false };
    };

    componentDidMount() {
        // 解决头菜单界面报错后点击菜单跳转不了问题
        store.subscribe(() => {
            const { errorFlag } = store.getState();
            if (errorFlag && this.state.hasError) {
                // 更新模式状态
                store.dispatch({
                    type: 'errorFlag',
                    data: false
                });
                this.setState({ hasError: false });
            };
        });
    };

    componentDidCatch(error, info) {
        this.setState({ hasError: true });
    };

    render() {
        if (this.state.hasError) {
            return <Error />;
        }
        return this.props.children;
    }
};

export default ErrorBoundary;