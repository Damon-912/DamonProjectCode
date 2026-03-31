/**
 * Purpose：全局方法注册
 */
import React from 'react';
import publicMethod from './tools/systemTools';

for (let name in publicMethod) {
    React['$' + name] = publicMethod[name];
}