import React from 'react';
import { Select } from 'antd';
import { Util } from '@tools';

const { Option } = Select;

/*
    * Purpose：    获取下拉列表的option
    * Params：     参数
        selectData [array] 下拉数据
        value [string] value值
        descripts [string] 描述
        descriptsSPCode [string] 搜索的值
    * */
export const SelectOptions = function (selectData, value = '', descripts = '', descriptsSPCode) {
    return selectData && Array.isArray(selectData) && selectData.length > 0 ? Util.unique(selectData, value || 'id').map((item, index) => {
        let id = value && value in item && item[value] ? item[value] : (item?.id || item?.value || '');
        let title = descripts && descripts in item && item[descripts] ? item[descripts] : (item?.descripts || item?.title || item?.label || item?.desc || '');
        let titleCode = descriptsSPCode ? item[descriptsSPCode] : ('descriptsSPCode' in item && item.descriptsSPCode ? item.descriptsSPCode : '');
        return (
            <Option
                disabled={item && item.disabled === 'Y' ? true : false}
                key={index}
                value={String(id)}
                seachprop={title + '^' + titleCode}
                search={title + '^' + titleCode}
                title={title}
            >
                {title}
            </Option>
        )
    }) : [];
}