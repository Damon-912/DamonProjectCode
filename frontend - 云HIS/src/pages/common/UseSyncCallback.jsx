import { useState, useEffect, useCallback } from 'react';

const UseSyncCallback = (callback) => {
    const [state, setState] = useState({ args: [], current: false });

    const Func = useCallback((...newArgs) => {
        setState({
            args: newArgs,
            current: true,
        });
    }, []);

    useEffect(() => {
        if (state.current === true) {
            callback(...state.args);
            setState(prevState => ({ ...prevState, current: false }));
        }
    }, [state]);

    return Func;
};

export default UseSyncCallback;